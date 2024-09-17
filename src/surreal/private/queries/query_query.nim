include shared_imports

# Send a custom query to SurrealDB
proc query*(db: SurrealDB, surql: SurQL): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendQuery(RpcMethod.Query, %* [ %* surql.string, %* {} ])

# Send a custom query to SurrealDB
proc query*(db: SurrealDB, surql: SurQL, params: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendQuery(RpcMethod.Query, %* [ %* surql.string, %* params ])