import std/[asyncdispatch, json, macros, tables, strutils, uri]
import ws

var queryFutures* = newTable[int, Future[JsonNode]]()

type
    NoneType* = distinct bool
    NullType* = distinct bool

    SurrealDB* = ref object
        ws*: WebSocket
        queryFutures*: TableRef[int, Future[JsonNode]]
        isConnected*: bool

macro Null*(): NullType =
  result = newCall(bindSym"NullType", newLit(true))

# For debugging purposes, you might want to add this:
proc `$`*(n: NullType): string = 
  "null"

macro None*(): NoneType =
  result = newCall(bindSym"NoneType", newLit(false))

# For debugging purposes, you might want to add this:
proc `$`*(n: NoneType): string = 
  "none"


proc startListenLoop(db: SurrealDB) {.async.} =
    echo "Starting listen loop"
    while db.isConnected:
        var resp = await db.ws.receivePacket()
        if resp[0] != Opcode.Text:
            continue
        let jsonObject = parseJson(resp[1])
        let queryId: int = jsonObject["id"].getInt()
        echo "Response for query ID: ", queryId
        if db.queryFutures.hasKey(queryId):
            let future = db.queryFutures[queryId]
            # echo "Located future for query ID: ", queryId
            db.queryFutures.del(queryId)
            # echo "Removed future for query ID: ", queryId
            future.complete(jsonObject)
            # echo "Completed future for query ID: ", queryId

            # TODO: Handle the case when the response is an error. This is the error format:
            # {"error":{"code":-32000,"message":"There was a problem with the database: Specify a database to use"},"id":4}
        else:
            echo "No future found for query ID: ", queryId


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