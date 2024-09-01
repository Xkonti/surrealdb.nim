import std/[asyncdispatch, asyncfutures, json, strutils, tables]
import ws
import ./core
import ./private/utils

proc sendQuery*(db: SurrealDB, query: string): Future[JsonNode] {.async.} =
    let queryId = getNextId()
    echo "Sending query with ID: ", queryId
    let future: Future[JsonNode] = newFuture[JsonNode]("sendQuery #" & $queryId)

    try:
        let queryWithId = query.replace("\"id\":-1", "\"id\":" & $queryId)
        await db.ws.send(queryWithId)
        db.queryFutures[queryId] = future
    except CatchableError as e:
        echo "Error sending query: ", e.msg
        future.fail(e)
    finally:
        return await future


proc use*(db: SurrealDB, namespace: string, database: string) {.async.} =
    let queryId = getNextId()
    let queryJson = %* { "id": queryId, "method": "use", "params": [ namespace, database ] }
    let future: Future[JsonNode] = newFuture[JsonNode]("db.use #" & $queryId)
    try:
        await db.ws.send($queryJson)
        db.queryFutures[queryId] = future
    except CatchableError as e:
        echo "Error sending 'use' query: ", e.msg
        future.fail(e)
    finally:
        discard await future
        return



proc select*(ws: WebSocket, params: string): Future[JsonNode] {.async.} =
    discard