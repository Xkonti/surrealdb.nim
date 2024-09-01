import std/[asyncdispatch, json, tables, strutils, uri]
import ws

var queryFutures* = newTable[int, Future[JsonNode]]()

type
    SurrealDB* = ref object
        ws*: WebSocket
        queryFutures*: TableRef[int, Future[JsonNode]]
        isConnected*: bool


proc startListenLoop(db: SurrealDB) {.async.} =
    echo "Starting listen loop"
    while db.isConnected:
        var resp = await db.ws.receivePacket()
        if resp[0] != Opcode.Text:
            continue
        let jsonObject = parseJson(resp[1])
        let queryId: int = jsonObject["id"].getInt()
        echo "Reqponse for query ID: ", queryId
        if db.queryFutures.hasKey(queryId):
            let future = db.queryFutures[queryId]
            db.queryFutures.del(queryId)
            future.complete(jsonObject)


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
        queryFutures: newTable[int, Future[JsonNode]](),
        isConnected: true
    )
    echo "Connected!"

    # Start loop that listens for responses from the database
    asyncCheck surreal.startListenLoop()

    return surreal


proc disconnect*(db: SurrealDB) =
    db.ws.close()
    db.isConnected = false