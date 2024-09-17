include shared_imports

proc version*(db: SurrealDB): Future[SurrealResult[JsonNode]] {.async.} =
    ## Returns the version information about the database / server.
    return await db.sendRpc(RpcMethod.Version, "")