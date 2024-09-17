include shared_imports

# TODO: Add variant that takes RecordId as a `thing`
# TODO: Add variant that takes a table string as a `thing`

proc delete*(db: SurrealDB, thing: string): Future[SurrealResult[JsonNode]] {.async.} =
    ## Deletes either a specified record or all records in the specified table
    return await db.sendRpc(RpcMethod.Delete, %* [ thing ])
