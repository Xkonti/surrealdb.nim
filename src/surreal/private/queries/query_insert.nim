include shared_imports
import std/[sequtils]

# TODO: Replace QueryParams with some proper type for passing contents

proc insert*(db: SurrealDB, table: string | TableName | RecordId, content: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    ## Insert a new record into the specified table
    return await db.sendRpc(RpcMethod.Insert, %* [ %* table, %* content ])

proc insert*(db: SurrealDB, table: string | TableName | RecordId, contents: seq[QueryParams]): Future[SurrealResult[JsonNode]] {.async.} =
    ## Insert multiple record into the specified table
    return await db.sendRpc(RpcMethod.Insert, %* [ %* table, %* contents ])

proc insert*(db: SurrealDB, table: string | TableName | RecordId, contents: varargs[QueryParams, toQueryParamsTable]): Future[SurrealResult[JsonNode]] =
    ## Insert multiple record into the specified table
    ## This wrapper makes sure that varargs are converted to a sequence as async procs can't handle varargs
    return insert(db, table, contents.toSeq)