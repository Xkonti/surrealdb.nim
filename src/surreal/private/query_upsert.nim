# TODO: Replace QueryParams with some proper type for passing contents

# Insert a new record or replace either all records in the table or a single record with the specified contents
# When the only a table is specified, this will run "update" on all records in the table
proc upsert*(db: SurrealDB, thing: string, content: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendQuery(RpcMethod.Upsert, %* [ %* thing, %* content ])

# TODO: Add variant that takes RecordId as a `thing`