include shared_imports

# Returns the version information about the database / server.
proc version*(db: SurrealDB): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendQuery(RpcMethod.Version, "")