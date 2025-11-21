import std/[asyncdispatch, tables, strutils, uri]
import ws

import ../types/[surrealdb, surrealResult, surrealValue, connection]
import ../cbor/[encoder, writer, decoder]
import ../utils

type
    WsCborConnection* = ref object of SurrealConnection
        ws*: WebSocket
        queryFutures*: TableRef[string, FutureResponse]
        isConnected*: bool

proc startListenLoop(conn: WsCborConnection) {.async.} =
    ## Initializes a loop that listens for WebSocket messagges.
    ## It matches received messages with the futures for sent queries and
    ## completes the futures with response contents.

    # TODO: Add a configuration option to either ignore errors or stop the loop
    while conn.isConnected:
        try:
            # Receive a message from the WebSocket
            let (opcode, message) = await conn.ws.receivePacket()
            case opcode
            of Opcode.Text:
                # Parse the message as JSON
                echo "Received message: ", message
            of Opcode.Binary:
                # Parse the message as CBOR
                let data = cast[seq[uint8]](message)
                var decodedMessage: SurrealValue
                try:
                    decodedMessage = decode(data)
                except CatchableError as e:
                    echo "Error decoding message: ", e.msg
                    continue

                # If no ID is present, we can't match it to a request future.
                if not decodedMessage.hasKey("id"):
                    echo "Malformed request received: ", decodedMessage
                    continue

                # Extract the ID of the request and locate the future
                let queryId: string = decodedMessage["id"].getString()
                # echo "Response for query ID: ", queryId

                # If counldn't find the future, we can't complete it, move on
                if not (conn.queryFutures.hasKey(queryId)):
                    echo "No future found for query ID: ", queryId
                    continue

                # Remove the future from the table - consider it handled
                let future = conn.queryFutures[queryId]
                conn.queryFutures.del(queryId)

                # If it's an error message, complete the future with the error
                if decodedMessage.hasKey("error"):
                    future.complete(surrealError(
                        decodedMessage["error"]["code"].toInt32(),
                        decodedMessage["error"]["message"].getString()))

                # Otherwise, complete the future with the response content
                else:
                    future.complete(surrealResponseValue(decodedMessage["result"]))
            of Opcode.Ping, Opcode.Pong:
                # Ignore ping and pong messages
                continue
            else:
                # Log unexpected messages
                echo "Received non-text and non-binary message: (", opcode, ") ", message
                continue
        except CatchableError as e:
            if conn.isConnected:
                echo "Error in listen loop: ", e.msg
                # TODO: Decide if we should reconnect or propagate error
                break

method connect*(this: WsCborConnection, url: string): Future[void] {.async.} =
    var address = parseUri(url)
    if address.scheme notin ["ws", "wss"]:
        raise newException(ValueError, "Invalid scheme for WsCborConnection: " & address.scheme)
    if not address.path.endsWith("rpc"):
        address = address / "rpc"

    this.ws = await newWebSocket($address, "cbor")
    this.ws.setupPings(15)
    this.queryFutures = newTable[string, FutureResponse]()
    this.isConnected = true

    asyncCheck this.startListenLoop()

method disconnect*(this: WsCborConnection) =
    if this.isConnected:
        this.isConnected = false
        this.ws.close()
        # Fail all pending futures?
        for id, future in this.queryFutures:
             if not future.finished:
                 future.fail(newException(IOError, "Connection closed"))
        this.queryFutures.clear()

method send*(this: WsCborConnection, methodStr: string, params: seq[SurrealValue]): Future[SurrealResult[SurrealValue]] {.async.} =
    let queryId = getNextId()
    let encoded = encode(%%* {
        "id": queryId,
        "method": methodStr,
        "params": params
    }).getOutput()

    let future: FutureResponse = newFuture[SurrealResult[SurrealValue]]("sendQuery '" & methodStr & "' #" & queryId)
    this.queryFutures[queryId] = future

    try:
        await this.ws.send(cast[string](encoded), Opcode.Binary)
        return await future
    except CatchableError as e:
        if not future.failed:
            future.fail(e)
            this.queryFutures.del(queryId)
        return await future
