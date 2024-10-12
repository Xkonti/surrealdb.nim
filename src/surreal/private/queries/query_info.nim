include shared_imports

proc info*(db: SurrealDB): Future[SurrealResult[SurrealValue]] {.async.} =
    ## Returns the record of an authenticated record user.
    return await db.sendRpc(RpcMethod.Info, @[])