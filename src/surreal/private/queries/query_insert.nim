include shared_imports
import std/[sequtils]

# TODO: Replace QueryParams with some proper type for passing contents

# Insert a new record into the specified table
proc insert*(db: SurrealDB, table: string, content: QueryParams): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendRpc(RpcMethod.Insert, %* [ %* table, %* content ])

# Insert multiple record into the specified table
proc insert*(db: SurrealDB, table: string, contents: seq[QueryParams]): Future[SurrealResult[JsonNode]] {.async.} =
    return await db.sendRpc(RpcMethod.Insert, %* [ %* table, %* contents ])

# Insert multiple record into the specified table
# This wrapper makes sure that varargs are converted to a sequence as async procs can't handle varargs
proc insert*(db: SurrealDB, table: string, contents: varargs[QueryParams, toQueryParamsTable]): Future[SurrealResult[JsonNode]] =
    return insert(db, table, contents.toSeq)