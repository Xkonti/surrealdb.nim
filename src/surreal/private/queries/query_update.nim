include shared_imports

proc update*(db: SurrealDB, thing: string | TableName | RecordId, content: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    ## Replace either all records in the table or a single record with the specified contents
    return await db.sendRpc(RpcMethod.Update, %* [ %* thing, %* content ])

# TODO: Add variant that takes RecordId as a `thing`