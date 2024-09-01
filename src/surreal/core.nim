import std/[asyncdispatch, json, tables]
import ws

var queryFutures* = newTable[int, Future[JsonNode]]()

type
    SurrealDB* = ref object
        ws*: WebSocket
        queryFutures*: TableRef[int, Future[JsonNode]]

proc newSurrealDB*(ws: WebSocket): SurrealDB =
    return SurrealDB(ws: ws, queryFutures: newTable[int, Future[JsonNode]]())


proc startListenLoop*(db: SurrealDB) {.async.} =
    echo "Starting listen loop"
    while true:
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