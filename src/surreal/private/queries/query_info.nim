include shared_imports

# Returns the record of an authenticated record user.
proc info*(db: SurrealDB): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendRpc(RpcMethod.Info, "")