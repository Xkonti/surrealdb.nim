import std/[asyncdispatch, asyncfutures, json, strutils, tables]
import ws
import ./core
import ./private/utils


proc sendQuery*(db: SurrealDB, query: JsonNode): Future[JsonNode] {.async.} =
    let queryId = query["id"].getInt()
    let queryMethod = query["method"].getStr()
    let future: Future[JsonNode] = newFuture[JsonNode]("sendQuery '" & queryMethod & "' #" & $queryId)
    try:
        await db.ws.send($query)
        db.queryFutures[queryId] = future
    except CatchableError as e:
        echo "Error sending query #", queryId, ": ", e.msg
        future.fail(e)
    finally:
        return await future


proc use*(db: SurrealDB, namespace: string, database: string) {.async.} =
    let queryId = getNextId()
    let queryJson = %* { "id": queryId, "method": "use", "params": [ namespace, database ] }
    discard await db.sendQuery(queryJson)
    return


proc signin*(db: SurrealDB, user: string, pass: string): Future[JsonNode] {.async.} =
    # TODO: Add support for other parameters
    let queryId = getNextId()
    let queryJson = %* { "id": queryId, "method": "signin", "params": [ { "user": user, "pass": pass } ] }
    return await db.sendQuery(queryJson)


proc select*(db: SurrealDB, thing: string): Future[JsonNode] {.async.} =
    # TODO: Adhere to the RPC docs
    let queryId = getNextId()
    let queryJson = %* { "id": queryId, "method": "select", "params": [ thing ] }
    return await db.sendQuery(queryJson)