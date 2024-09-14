# TODO: Replace QueryParams with some proper type for passing contents

# Replace either all records in the table or a single record with the specified contents
proc update*(db: SurrealDB, thing: string, content: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendQuery(RpcMethod.Update, %* [ %* thing, %* content ])

# TODO: Add variant that takes RecordId as a `thing`