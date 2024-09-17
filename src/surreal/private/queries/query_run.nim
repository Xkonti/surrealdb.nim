include shared_imports

proc runFunction*(db: SurrealDB, name: string, params: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    ## Run a SurrealQL function
    return await db.sendRpc(RpcMethod.Run, %* [ %* name, newJNull(), %* params ])

proc runModel*(db: SurrealDB, name: string, version: string, params: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    ## Run a SurrealQL machine learning model (function)
    return await db.sendRpc(RpcMethod.Run, %* [ %* name, %* version, %* params ])