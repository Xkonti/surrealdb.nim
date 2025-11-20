import std/asyncdispatch
import ../types/[rpcMethod, surrealdb, surrealValue, surrealResult]
import ../utils

proc sendRpc*(db: SurrealDB, queryMethod: RpcMethod, params: seq[SurrealValue]): Future[SurrealResult[SurrealValue]] {.async.} =
    ## Sends an RPC request through the engine.
    ##
    ## This is the core method that all query operations use to communicate with SurrealDB.
    ## The actual transport and serialization is handled by the engine (WebSocket+CBOR, gRPC+Protobuf, etc.).
    ##
    ## Parameters:
    ## - db: SurrealDB connection object
    ## - queryMethod: RPC method to invoke (select, signin, create, etc.)
    ## - params: Sequence of parameters for the RPC method
    ##
    ## Returns:
    ## - Future that completes with the query result or error

    # Generate a unique ID for the request (used for request/response matching in some engines)
    let queryId = getNextId()

    # Delegate to the engine's sendRequest method
    return await db.engine.sendRequest(queryId, $queryMethod, params)