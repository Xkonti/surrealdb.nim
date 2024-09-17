include shared_imports

# TODO: Replace QueryParams with some proper type for passing contents
# TODO: Add variant that takes RecordId as a `thing`

# Create a new record either with a random or specified ID
proc create*(db: SurrealDB, thing: string, content: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendRpc(RpcMethod.Create, %* [ %* thing, %* content ])
