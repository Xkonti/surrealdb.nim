# Run a SurrealQL function
proc runFunction*(db: SurrealDB, name: string, params: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendQuery(RpcMethod.Run, %* [ %* name, newJNull(), %* params ])

# Run a SurrealQL machine learning model (function)
proc runModel*(db: SurrealDB, name: string, version: string, params: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendQuery(RpcMethod.Run, %* [ %* name, %* version, %* params ])