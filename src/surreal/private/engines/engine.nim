## Base abstraction for RPC communication engines.
##
## This module defines the core RpcEngine interface that all concrete engine
## implementations must implement. An engine encapsulates both the transport
## mechanism (WebSocket, gRPC, etc.) and the serialization protocol (CBOR,
## Protobuf, FlatBuffers, etc.).

import std/[asyncdispatch, tables]
import ../types/[surrealResult, surrealValue]

type
    RpcEngine* = ref object of RootObj
        ## Abstract base type for RPC communication engines.
        ##
        ## Each concrete engine implementation handles:
        ## - Transport: WebSocket, HTTP/2 (gRPC), etc.
        ## - Serialization: CBOR, Protobuf, FlatBuffers, etc.
        ## - Request/Response matching (if needed)
        ## - Connection lifecycle management
        ##
        ## Implementations:
        ## - WebSocketCborEngine: WebSocket + CBOR (current)
        ## - GrpcProtobufEngine: gRPC + Protobuf (future)
        ## - GrpcFlatbuffersEngine: gRPC + FlatBuffers (future)

        queryFutures*: TableRef[string, FutureResponse]
            ## Maps request IDs to futures awaiting responses.
            ## Used by engines that need async request/response matching (e.g., WebSocket).
            ## gRPC engines may not need this as gRPC handles request-response pairing.

        connected*: bool
            ## Connection state flag.

# ============================================================================
# Core Engine Interface
# ============================================================================

method sendRequest*(
    engine: RpcEngine,
    id: string,
    methodName: string,
    params: seq[SurrealValue]
): Future[SurrealResult[SurrealValue]] {.base, async.} =
    ## Sends an RPC request through the engine and returns a future for the response.
    ##
    ## Parameters:
    ## - id: Unique request identifier (for request/response matching)
    ## - methodName: RPC method name (e.g., "select", "signin", "query")
    ## - params: Sequence of parameters for the RPC method
    ##
    ## Returns:
    ## - Future that completes with the RPC response or error
    ##
    ## Notes:
    ## - Concrete engines must override this method
    ## - WebSocket engines will encode as CBOR and send over WS
    ## - gRPC engines will convert to Protobuf and call gRPC service
    raise newException(CatchableError, "sendRequest not implemented for this engine")


method close*(engine: RpcEngine) {.base.} =
    ## Closes the engine connection and cleans up resources.
    ##
    ## This method should:
    ## - Close the underlying transport (WebSocket, gRPC channel, etc.)
    ## - Cancel or fail any pending futures
    ## - Clean up background tasks (listen loops, etc.)
    ## - Set connected flag to false
    ##
    ## Notes:
    ## - Concrete engines must override this method
    raise newException(CatchableError, "close not implemented for this engine")


method isConnected*(engine: RpcEngine): bool {.base.} =
    ## Returns whether the engine is currently connected.
    ##
    ## Returns:
    ## - true if the engine is connected and ready to send requests
    ## - false if disconnected, connecting, or in error state
    ##
    ## Default implementation returns the connected flag.
    ## Engines can override to provide more sophisticated connection checking.
    return engine.connected
