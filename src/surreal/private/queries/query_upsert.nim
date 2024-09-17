include shared_imports

# TODO: Replace QueryParams with some proper type for passing contents

proc upsert*(db: SurrealDB, thing: string | TableName | RecordId, content: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    ## Insert a new record or replace either all records in the table or a single record with the specified contents
    ## When the only a table is specified, this will run "update" on all records in the table
    return await db.sendRpc(RpcMethod.Upsert, %* [ %* thing, %* content ])
