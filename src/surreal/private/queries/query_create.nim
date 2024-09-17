include shared_imports

# TODO: Replace QueryParams with some proper type for passing contents

proc create*(db: SurrealDB, thing: string | TableName | RecordId, content: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    ## Create a new record either with a random or specified ID
    return await db.sendRpc(RpcMethod.Create, %* [ %* thing, %* content ])