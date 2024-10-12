include shared_imports

proc runFunction*(db: SurrealDB, name: string): Future[SurrealResult[SurrealValue]] {.async.} =
    ## Run a SurrealQL function
    return await db.sendRpc(RpcMethod.Run, @[ %%% name, surrealNull ])

proc runFunction*(db: SurrealDB, name: string, params: SurrealValue): Future[SurrealResult[SurrealValue]] {.async.} =
    ## Run a SurrealQL function
    var params = params
    if params.kind != SurrealArray:
        params = @[params].toSurrealArray()
    return await db.sendRpc(RpcMethod.Run, @[ %%% name, surrealNull, params ])

proc runModel*(db: SurrealDB, name: string, version: string): Future[SurrealResult[SurrealValue]] {.async.} =
    ## Run a SurrealQL machine learning model (function)
    return await db.sendRpc(RpcMethod.Run, @[ %%% name, %%% version ])

proc runModel*(db: SurrealDB, name: string, version: string, params: SurrealValue): Future[SurrealResult[SurrealValue]] {.async.} =
    ## Run a SurrealQL machine learning model (function)
    var params = params
    if params.kind != SurrealArray:
        params = @[params].toSurrealArray()
    return await db.sendRpc(RpcMethod.Run, @[ %%% name, %%% version, params ])