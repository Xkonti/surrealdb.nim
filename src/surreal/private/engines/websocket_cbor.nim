## WebSocket + CBOR RPC engine implementation.
##
## This engine implements the current SurrealDB RPC protocol:
## - Transport: WebSocket with "cbor" subprotocol
## - Serialization: CBOR encoding/decoding
## - Request format: { "id": string, "method": string, "params": array }
## - Response format: { "id": string, "result": value } or { "id": string, "error": {...} }

import std/[asyncdispatch, asyncfutures, strutils, tables, uri]
import ws

import engine
import ../types/[surrealResult, surrealValue]
import ../cbor/[encoder, decoder, writer]
import ../utils

type
    WebSocketCborEngine* = ref object of RpcEngine
        ## WebSocket + CBOR engine for SurrealDB RPC.
        ##
        ## This engine:
        ## - Establishes WebSocket connection with "cbor" subprotocol
        ## - Encodes RPC requests as CBOR binary messages
        ## - Runs background loop to receive and decode CBOR responses
        ## - Matches responses to request futures by ID

        ws: WebSocket
            ## The underlying WebSocket connection

        listenTask: Future[void]
            ## Background task that listens for incoming WebSocket messages


# ============================================================================
# Constructor
# ============================================================================

proc newWebSocketCborEngine*(url: string): Future[WebSocketCborEngine] {.async.} =
    ## Creates and connects a new WebSocket CBOR engine.
    ##
    ## Parameters:
    ## - url: WebSocket URL (ws:// or wss://). Path will be adjusted to end with "/rpc" if needed.
    ##
    ## Returns:
    ## - Connected WebSocketCborEngine ready to send requests
    ##
    ## Raises:
    ## - ValueError: if URL scheme is not ws or wss
    ## - WebSocket connection errors

    # Verify that the URL is valid and adjust it if necessary
    var address = parseUri(url)
    if address.scheme notin ["ws", "wss"]:
        raise newException(ValueError, "Invalid scheme for WebSocket: " & address.scheme & " (expected ws or wss)")
    if not address.path.endsWith("rpc"):
        address = address / "rpc"

    # Establish the WebSocket connection with CBOR subprotocol
    let ws = await newWebSocket($address, "cbor")

    # Setup periodic pings (every 15 seconds)
    ws.setupPings(15)

    # Create the engine object
    let engine = WebSocketCborEngine(
        ws: ws,
        queryFutures: newTable[string, FutureResponse](),
        connected: true,
        listenTask: nil  # Will be set after starting listen loop
    )

    echo "WebSocket connected to ", $address

    # Start background loop that listens for responses from the database
    engine.listenTask = engine.startListenLoop()
    asyncCheck engine.listenTask

    return engine


# ============================================================================
# Listen Loop (Response Handling)
# ============================================================================

proc startListenLoop(engine: WebSocketCborEngine) {.async.} =
    ## Background loop that listens for WebSocket messages.
    ##
    ## This loop:
    ## - Receives binary WebSocket messages
    ## - Decodes CBOR data
    ## - Extracts request ID from response
    ## - Completes the corresponding future with result or error
    ##
    ## The loop runs until the engine is disconnected.

    echo "Starting WebSocket listen loop"

    # TODO: Add a configuration option to either ignore errors or stop the loop
    while engine.connected:
        try:
            # Receive a message from the WebSocket
            let (opcode, message) = await engine.ws.receivePacket()

            case opcode
            of Opcode.Text:
                # Unexpected text message (should be binary CBOR)
                echo "Received unexpected text message: ", message

            of Opcode.Binary:
                # Parse the message as CBOR
                let data = cast[seq[uint8]](message)

                # Decode CBOR message
                var decodedMessage: SurrealValue
                try:
                    decodedMessage = decode(data)
                except CatchableError as e:
                    echo "Error decoding CBOR message: ", e.msg
                    continue

                # Extract request ID (required for matching to future)
                if not decodedMessage.hasKey("id"):
                    echo "Malformed response received (missing 'id'): ", decodedMessage
                    continue

                let queryId: string = decodedMessage["id"].getString()
                echo "Response for query ID: ", queryId

                # Find the future for this request
                if not (engine.queryFutures.hasKey(queryId)):
                    echo "No future found for query ID: ", queryId
                    continue

                # Remove the future from the table - consider it handled
                let future = engine.queryFutures[queryId]
                engine.queryFutures.del(queryId)

                # Complete the future with result or error
                if decodedMessage.hasKey("error"):
                    # Error response: { "id": "...", "error": { "code": int, "message": string } }
                    future.complete(surrealError(
                        decodedMessage["error"]["code"].toInt32(),
                        decodedMessage["error"]["message"].getString()))
                else:
                    # Success response: { "id": "...", "result": value }
                    future.complete(surrealResponseValue(decodedMessage["result"]))

            of Opcode.Ping, Opcode.Pong:
                # Ignore ping/pong messages (handled by ws library)
                continue

            else:
                # Log unexpected opcodes
                echo "Received unexpected WebSocket opcode: ", opcode

        except CatchableError as e:
            # If we encounter an error, log it and continue (unless disconnected)
            if engine.connected:
                echo "Error in WebSocket listen loop: ", e.msg
            else:
                # Engine was disconnected, exit loop
                break

    echo "WebSocket listen loop stopped"


# ============================================================================
# RpcEngine Interface Implementation
# ============================================================================

method sendRequest*(
    engine: WebSocketCborEngine,
    id: string,
    methodName: string,
    params: seq[SurrealValue]
): Future[SurrealResult[SurrealValue]] {.async.} =
    ## Sends an RPC request over WebSocket using CBOR encoding.
    ##
    ## Request format (CBOR):
    ## {
    ##   "id": string,
    ##   "method": string,
    ##   "params": [param1, param2, ...]
    ## }
    ##
    ## Returns a future that will be completed when the response is received
    ## in the listen loop.

    # Encode request as CBOR
    let encoded = encode(%%* {
        "id": id,
        "method": methodName,
        "params": params
    }).getOutput()

    # Create and register a new future for the request
    let future: FutureResponse = newFuture[SurrealResult[SurrealValue]](
        "sendRequest '" & methodName & "' #" & id)
    engine.queryFutures[id] = future

    # Attempt to send the request and return the result
    try:
        await engine.ws.send(cast[string](encoded), Opcode.Binary)
        return await future

    except CatchableError as e:
        # If there was an error when sending the request, fail the future
        # Check if the future failed already
        if not future.failed:
            echo "Error sending query #", id, ": ", e.msg
            # Remove the future from the table ASAP
            # As it's not possible to get a response for a query that wasn't sent
            engine.queryFutures.del(id)
            future.fail(e)

        return await future


method close*(engine: WebSocketCborEngine) =
    ## Closes the WebSocket connection and cleans up resources.
    ##
    ## This method:
    ## - Sets connected flag to false (stops listen loop)
    ## - Closes the WebSocket connection
    ## - Fails all pending futures

    echo "Closing WebSocket connection"

    engine.connected = false
    engine.ws.close()

    # Fail all pending futures
    for id, future in engine.queryFutures.pairs:
        if not future.finished:
            future.fail(newException(IOError, "Connection closed"))
    engine.queryFutures.clear()
