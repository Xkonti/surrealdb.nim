include shared_imports

# TODO: Allow passing multiple records to in and out
# TODO: Allow passing data as a fourth parameter

proc relate*(db: SurrealDB, `in`: string | RecordId, relation: string | TableName, `out`: string | RecordId): Future[SurrealResult[JsonNode]] {.async.} =
    ## Relates two records with a specified relation
    return await db.sendRpc(RpcMethod.Relate, %* [ %* `in`, %* relation, %* `out` ])