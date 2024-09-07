import std/[asyncdispatch, json]
import ./core
import ./private/common

# Returns the record of an authenticated record user.
proc info*(db: SurrealDB): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendQuery(RpcMethod.Info, "")