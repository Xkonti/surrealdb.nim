include shared_imports
import ../types/surql

# Select all records in the provied table or the specified record
proc select*(db: SurrealDB, table: string): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendQuery(RpcMethod.Select, %* [ table ])

# Select the specified thing
proc select*(db: SurrealDB, thing: SurQL): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendQuery(RpcMethod.Select, """[ $1 ]""" % [ thing.string ])

# TODO: Select the specified record
# proc select*(db: SurrealDB, recordId: RecordId): Future[SurrealResult[JsonNode]] {.async.} =
#     return await db.sendQuery(RpcMethod.Select, %* [ table ])