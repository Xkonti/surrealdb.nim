include shared_imports

# TODO: Support selecting multiple records by passing an array

proc select*(db: SurrealDB, table: string | TableName | RecordId): Future[SurrealResult[JsonNode]] {.async.} =
    ## Select all records in the provied table or the specified record
    return await db.sendRpc(RpcMethod.Select, %* [ %* table ])
