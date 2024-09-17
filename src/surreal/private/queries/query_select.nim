include shared_imports
import ../types/surql

proc select*(db: SurrealDB, table: string): Future[SurrealResult[JsonNode]] {.async.} =
    ## Select all records in the provied table or the specified record
    return await db.sendRpc(RpcMethod.Select, %* [ table ])

proc select*(db: SurrealDB, thing: SurQL): Future[SurrealResult[JsonNode]] {.async.} =
    ## Select the specified thing
    return await db.sendRpc(RpcMethod.Select, """[ $1 ]""" % [ thing.string ])

# TODO: Select the specified record
# proc select*(db: SurrealDB, recordId: RecordId): Future[SurrealResult[JsonNode]] {.async.} =
#     return await db.sendRpc(RpcMethod.Select, %* [ table ])