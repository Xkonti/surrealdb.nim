include shared_imports
import ../types/surql

proc query*(db: SurrealDB, surql: SurQL): Future[SurrealResult[SurrealValue]] {.async.} =
    ## Send a custom query to SurrealDB
    return await db.sendRpc(RpcMethod.Query, @[ %%% surql.string ])

proc query*(db: SurrealDB, surql: SurQL, params: SurrealValue): Future[SurrealResult[SurrealValue]] {.async.} =
    ## Send a custom query to SurrealDB
    return await db.sendRpc(RpcMethod.Query, @[ %%% surql.string, params ])