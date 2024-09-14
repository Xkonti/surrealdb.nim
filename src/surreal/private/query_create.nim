# TODO: Replace QueryParams with some proper type for passing contents

# Create a new record either with a random or specified ID
proc create*(db: SurrealDB, thing: string, content: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendQuery(RpcMethod.Create, %* [ %* thing, %* content ])

# TODO: Add variant that takes RecordId as a `thing`