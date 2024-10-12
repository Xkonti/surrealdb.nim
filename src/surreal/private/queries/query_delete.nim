include shared_imports

proc delete*(db: SurrealDB, thing: TableName | RecordId): Future[SurrealResult[SurrealValue]] {.async.} =
    ## Deletes either a specified record or all records in the specified table
    return await db.sendRpc(RpcMethod.Delete, @[ %%% thing ])