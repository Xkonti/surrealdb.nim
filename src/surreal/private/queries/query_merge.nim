include shared_imports

proc merge*(db: SurrealDB, thing: TableName | RecordId, content: SurrealValue): Future[SurrealResult[SurrealValue]] {.async.} =
    ## Merges the specified contents with either all records in the table or a single record
    return await db.sendRpc(RpcMethod.Merge, @[ %%% thing, content ])
