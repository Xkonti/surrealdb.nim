include shared_imports

# TODO: Replace QueryParams with some proper type for passing contents
# TODO: Add variant that takes RecordId as a `thing`

proc merge*(db: SurrealDB, thing: string, content: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    ## Merges the specified contents with either all records in the table or a single record
    return await db.sendRpc(RpcMethod.Merge, %* [ %* thing, %* content ])
