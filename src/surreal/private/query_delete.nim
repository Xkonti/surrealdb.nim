# TODO: Add variant that takes RecordId as a `thing`
# TODO: Add variant that takes a table string as a `thing`

# Deletes either a specified record or all records in the specified table
proc delete*(db: SurrealDB, thing: string): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendQuery(RpcMethod.Delete, %* [ thing ])
