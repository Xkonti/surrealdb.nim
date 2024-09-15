# TODO: Replace QueryParams with some proper type for passing contents
# TODO: Add variant that takes RecordId as a `thing`

# Merges the specified contents with either all records in the table or a single record
proc merge*(db: SurrealDB, thing: string, content: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendQuery(RpcMethod.Merge, %* [ %* thing, %* content ])
