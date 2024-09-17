import std/[asyncdispatch, json, macros, tables, strutils, uri]
import ws
import types/[none, null]

var queryFutures* = newTable[int, Future[JsonNode]]()

include core_surql
include core_queryParams
include core_result
include core_surrealResult

type
    SurrealDB* = ref object
        ws*: WebSocket
        # TODO: Add a timeout for each future in case the response is not received / can't be linked to the request
        queryFutures*: TableRef[int, FutureResponse]
        isConnected*: bool

## Initializes a loop that listens for WebSocket messagges.
## It matches received messages with the futures for sent queries and
## completes the futures with response contents.
proc startListenLoop(db: SurrealDB) {.async.} =
    echo "Starting listen loop"
    while db.isConnected:
        # Receive a message from the WebSocket
        var resp = await db.ws.receivePacket()
        if resp[0] != Opcode.Text:
            # Ignore non-text messages
            continue

        # Parse the message as JSON
        let jsonObject = parseJson(resp[1])

        # If no ID is present, we can't match it to a request future.
        # Most likely the request was malformed and the server couldn't extract the ID from it.
        if not jsonObject.hasKey("id"):
            echo "Malformed request received: ", jsonObject
            continue

        # Extract the ID of the request and locate the future
        let queryId: int = jsonObject["id"].getInt()
        echo "Response for query ID: ", queryId

        # If counldn't find the future, we can't complete it, move on
        if not db.queryFutures.hasKey(queryId):
            echo "No future found for query ID: ", queryId
            continue

        # Remove the future from the table - consider it handled
        let future = db.queryFutures[queryId]
        db.queryFutures.del(queryId)

        # If it's an error message, complete the future with the error
        if jsonObject.hasKey("error"):
            future.complete(surrealError(
                jsonObject["error"]["code"].getInt(),
                jsonObject["error"]["message"].getStr()))
        # Otherwise, complete the future with the response content
        else:
            future.complete(surrealResponseJson(jsonObject["result"]))



proc newSurrealDbConnection*(url: string): Future[SurrealDB] {.async.} =
    # Verify that the URL is valid and adjust it if necessary
    var address = parseUri(url)
    if address.scheme notin ["ws", "wss"]:
        raise newException(ValueError, "Invalid scheme: " & address.scheme)
    if not address.path.endsWith("rpc"):
        address = address / "rpc"

    # Establish the WebSocket connection
    let ws = await newWebSocket($address)

    # Setup the pings
    ws.setupPings(15)

    # Create the SurrealDB object
    let surreal = SurrealDB(
        ws: ws,
        queryFutures: newTable[int, FutureResponse](),
        isConnected: true
    )
    echo "Connected!"

    # Start loop that listens for responses from the database
    asyncCheck surreal.startListenLoop()

    return surreal


proc disconnect*(db: SurrealDB) =
    db.ws.close()
    db.isConnected = false