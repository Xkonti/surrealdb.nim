include shared_imports

# TODO: Replace in and out with proper RecordID type
# TODO: Replace relation with proper string type
# TODO: Allow passing multiple records to in and out
# TODO: Allow passing data as a fourth parameter

# Relates two records with a specified relation
proc relate*(db: SurrealDB, `in`: string, relation: string, `out`: string): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendRpc(RpcMethod.Relate, %* [ `in`, relation, `out` ])