import ../engines/engine

type
    SurrealDB* = ref object
        ## The SurrealDB connection object.
        ##
        ## This object provides access to all SurrealDB RPC methods (select, signin, create, etc.).
        ## The actual transport and protocol implementation is abstracted into the engine field,
        ## allowing support for multiple backends (WebSocket+CBOR, gRPC+Protobuf, etc.).

        engine*: RpcEngine
            ## The RPC engine that handles transport and serialization.
            ## Current implementations:
            ## - WebSocketCborEngine: WebSocket + CBOR (current protocol)
            ## Future implementations:
            ## - GrpcProtobufEngine: gRPC + Protobuf
            ## - GrpcFlatbuffersEngine: gRPC + FlatBuffers