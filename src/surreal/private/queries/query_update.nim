include shared_imports

proc update*(db: SurrealDB, thing: TableName | RecordId, content: SurrealValue): Future[SurrealResult[SurrealValue]] {.async.} =
    ## Replace either all records in the table or a single record with the specified contents
    return await db.sendRpc(RpcMethod.Update, @[ %%% thing, content ])

# TODO: Why does this not work?
# template update*(db: SurrealDB, thing: TableName | RecordId, content: untyped): untyped =
#     ## Replace either all records in the table or a single record with the specified contents
#     db.update(thing, %%* content)