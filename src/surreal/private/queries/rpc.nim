import std/[asyncdispatch, asyncfutures, strutils, tables]
import ../types/[rpcMethod, surrealdb, surrealValue, surrealResult, connection]

proc sendRpc*(db: SurrealDB, queryMethod: RpcMethod, params: seq[SurrealValue]): Future[SurrealResult[SurrealValue]] {.async.} =
    # Delegate the RPC call to the underlying connection
    return await db.connection.send($queryMethod, params)
