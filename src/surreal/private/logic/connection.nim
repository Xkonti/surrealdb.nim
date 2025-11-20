import std/[asyncdispatch, uri]

import ../types/surrealdb
import ../engines/[engine, websocket_cbor]

proc newSurrealDbConnection*(url: string): Future[SurrealDB] {.async.} =
    ## Creates a new SurrealDB connection using the appropriate engine based on URL scheme.
    ##
    ## Supported URL schemes:
    ## - ws://, wss://  -> WebSocketCborEngine (current protocol)
    ## - grpc://, grpcs:// -> GrpcProtobufEngine (future, when implemented)
    ##
    ## Parameters:
    ## - url: Connection URL with appropriate scheme
    ##
    ## Returns:
    ## - Connected SurrealDB instance ready to execute queries
    ##
    ## Raises:
    ## - ValueError: if URL scheme is not supported
    ## - Connection errors from the underlying engine

    let uri = parseUri(url)

    # Select and create the appropriate engine based on URL scheme
    let engine: RpcEngine = case uri.scheme
        of "ws", "wss":
            await newWebSocketCborEngine(url)
        # Future engine types:
        # of "grpc", "grpcs":
        #     await newGrpcProtobufEngine(url)
        else:
            raise newException(ValueError,
                "Unsupported URL scheme: " & uri.scheme &
                " (supported: ws, wss)")

    return SurrealDB(engine: engine)


proc disconnect*(db: SurrealDB) =
    ## Disconnects the SurrealDB connection.
    ##
    ## This closes the underlying engine connection and cleans up all resources,
    ## including failing any pending request futures.

    db.engine.close()