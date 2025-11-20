# RPC Abstraction Design

**Status**: Implementation in progress
**Author**: Claude
**Date**: 2025-11-20

## Overview

This document describes the redesign of the surrealdb.nim architecture to support multiple transport mechanisms (WebSocket, gRPC) and serialization protocols (CBOR, Protobuf, FlatBuffers) while maintaining a simple, Nim-idiomatic design.

## Problem Statement

### Current Architecture Limitations

1. **Tight Coupling**: The `SurrealDB` type directly contains `ws: WebSocket`, coupling it to WebSocket transport
2. **Hardcoded Protocol**:
   - `sendRpc` hardcodes CBOR encoding
   - `listenLoop` hardcodes CBOR decoding
3. **No Abstraction**: Transport and serialization are inseparable from business logic
4. **Migration Barrier**: Moving to gRPC would require rewriting core connection logic

### Requirements

1. **Nim-Idiomatic**: Simple, clear code using Nim's built-in features (no over-engineering)
2. **Transport Agnostic**: Support WebSocket and future gRPC transports
3. **Protocol Agnostic**: Support CBOR, Protobuf, and FlatBuffers serialization
4. **Transparent to Users**: Existing API should remain unchanged
5. **Easy Migration**: Clear path from current WebSocket/CBOR to gRPC

## Design Philosophy

### Key Insight: Transport and Protocol Are Often Coupled

Unlike some architectures that separate transport from serialization, we recognize that:
- WebSocket connections typically use CBOR for SurrealDB
- gRPC inherently bundles HTTP/2 transport with Protobuf/FlatBuffers
- Attempting to mix-and-match (e.g., gRPC with CBOR) adds unnecessary complexity

**Solution**: Abstract transport + protocol together as an "Engine"

### Inspiration from JavaScript SDK

The [surrealdb.js SDK](https://github.com/surrealdb/surrealdb.js/blob/f1809173e34fdea4d383ed3952df02dce6dbe037/packages/sdk/src/types/surreal.ts#L27) uses:
- `SurrealProtocol`: Interface defining RPC operations
- `SurrealEngine`: Extends protocol with lifecycle management
- `EngineFactory`: Factory pattern for pluggable implementations

Our Nim adaptation achieves the same goals more simply using method dispatch.

## Architecture Design

### Layer 1: Engine Abstraction

```nim
type
  RpcEngine* = ref object of RootObj
    ## Abstract base for RPC communication engines.
    ## Each engine implements both transport (WebSocket, HTTP/2)
    ## and serialization (CBOR, Protobuf, FlatBuffers).
    queryFutures*: TableRef[string, FutureResponse]
    connected*: bool
```

**Core Interface**:

```nim
method sendRequest*(
  engine: RpcEngine,
  id: string,
  methodName: string,
  params: seq[SurrealValue]
): Future[SurrealResult[SurrealValue]] {.base, async.} =
  ## Sends an RPC request and returns a future for the response

method close*(engine: RpcEngine) {.base.} =
  ## Closes the engine and cleans up resources

method isConnected*(engine: RpcEngine): bool {.base.} =
  ## Returns whether the engine is currently connected
```

### Layer 2: Concrete Engine Implementations

#### WebSocketCborEngine (Current Protocol)

```nim
type
  WebSocketCborEngine* = ref object of RpcEngine
    ws: WebSocket
    listenTask: Future[void]  # Background task for receiving messages
```

**Responsibilities**:
- Establish WebSocket connection with "cbor" protocol
- Encode requests as CBOR: `{ "id": string, "method": string, "params": array }`
- Send binary messages over WebSocket
- Listen for responses in background loop
- Decode CBOR responses
- Match responses to request futures by ID

**Implementation Notes**:
- Migrates existing code from `connection.nim`, `rpc.nim`, and `listenLoop.nim`
- No changes to CBOR encoding/decoding logic
- Request/response matching remains ID-based (WebSocket is asynchronous)

#### GrpcProtobufEngine (Future Protocol)

```nim
type
  GrpcProtobufEngine* = ref object of RpcEngine
    client: SurrealDBServiceClient  # Generated gRPC stub
    session: GrpcSession            # Session state management
```

**Responsibilities**:
- Establish gRPC connection using HTTP/2
- Convert `SurrealValue` params to Protobuf messages
- Call appropriate gRPC service method based on `methodName`
- Convert Protobuf responses back to `SurrealValue`
- Handle gRPC-specific authentication and session management

**Implementation Notes**:
- No request/response matching needed (gRPC is request-response paired)
- Method mapping: `"select"` → `client.Select(SelectRequest)`
- Will be implemented after gRPC protocol stabilizes

#### GrpcFlatbuffersEngine (Future Alternative)

Similar to GrpcProtobufEngine but uses FlatBuffers serialization instead of Protobuf. Decision between Protobuf/FlatBuffers will be based on SurrealDB's final protocol choice.

### Layer 3: Main Connection Object

```nim
type
  SurrealDB* = ref object
    engine*: RpcEngine  # Polymorphic engine reference
```

**Changes from Current Implementation**:
- Replace `ws: WebSocket` with `engine: RpcEngine`
- Remove `queryFutures` and `isConnected` (now in engine)
- All public methods remain unchanged

**Engine Selection**:

```nim
proc newSurrealDbConnection*(url: string): Future[SurrealDB] {.async.} =
  let uri = parseUri(url)

  let engine: RpcEngine = case uri.scheme
    of "ws", "wss":
      await newWebSocketCborEngine(url)
    of "grpc", "grpcs":
      await newGrpcProtobufEngine(url)
    else:
      raise newException(ValueError, "Unsupported scheme: " & uri.scheme)

  return SurrealDB(engine: engine)
```

Users can connect with:
- `ws://localhost:8000/rpc` → WebSocketCborEngine
- `grpc://localhost:9000` → GrpcProtobufEngine

### Layer 4: Query Methods

**Minimal Changes**:

```nim
proc sendRpc*(
  db: SurrealDB,
  queryMethod: RpcMethod,
  params: seq[SurrealValue]
): Future[SurrealResult[SurrealValue]] {.async.} =
  let queryId = getNextId()
  return await db.engine.sendRequest(queryId, $queryMethod, params)
```

All 26+ query methods (select, signin, create, etc.) remain **completely unchanged**.

## Directory Structure

```
src/surreal/private/
├── engines/
│   ├── engine.nim              # RpcEngine base type + interface
│   ├── websocket_cbor.nim      # WebSocketCborEngine implementation
│   └── grpc_protobuf.nim       # GrpcProtobufEngine (future)
├── cbor/                       # CBOR codec (unchanged, used by websocket_cbor)
│   ├── constants.nim
│   ├── types.nim
│   ├── reader.nim
│   ├── writer.nim
│   ├── decoder.nim
│   └── encoder.nim
├── grpc/                       # gRPC/Protobuf codec (future)
│   ├── generated/              # Generated from .proto files
│   │   ├── rpc.pb.nim
│   │   └── ...
│   └── codec.nim               # SurrealValue ↔ Protobuf conversion
├── types/                      # Minor changes
│   ├── surrealdb.nim           # Updated: engine field instead of ws
│   ├── surrealValue.nim        # Unchanged
│   ├── surrealResult.nim       # Unchanged
│   └── ...
├── queries/                    # Minimal changes
│   ├── rpc.nim                 # Updated: use db.engine
│   ├── query_select.nim        # Unchanged
│   └── ...
└── logic/                      # Removed (logic moved to engines/)
    ├── connection.nim          # → engines/websocket_cbor.nim
    └── listenLoop.nim          # → engines/websocket_cbor.nim
```

## Key Design Decisions

### Why Combine Transport + Protocol in Engine?

**Alternatives Considered**:
1. **Separate Abstraction**: `Transport` (WebSocket/HTTP2) + `Codec` (CBOR/Protobuf)
   - **Rejected**: More complex, allows nonsensical combinations (gRPC + CBOR)
   - **Rejected**: Two abstractions to maintain instead of one

2. **Protocol-First**: Abstract only serialization, keep transport separate
   - **Rejected**: gRPC tightly couples HTTP/2 and Protobuf
   - **Rejected**: Leaks transport details into query logic

**Chosen Approach**: Engine = Transport + Protocol
- **Simple**: Single abstraction point
- **Natural**: Matches how protocols are actually bundled (gRPC = HTTP/2 + Protobuf)
- **Flexible**: Can still split later if needed

### Why Method Dispatch Over Factory Pattern?

**JavaScript SDK** uses factory pattern + registry:
```typescript
type EngineFactory = (context: DriverContext) => SurrealEngine
type Engines = Record<string, EngineFactory>
```

**Nim Approach** uses method dispatch + URL-based selection:
```nim
method sendRequest*(engine: RpcEngine, ...): Future[...] {.base, async.}
# WebSocketCborEngine overrides sendRequest
# GrpcProtobufEngine overrides sendRequest
```

**Rationale**:
- **Simpler**: No factory indirection, no registry management
- **Nim-Idiomatic**: Method dispatch is standard OOP in Nim
- **Sufficient**: URL scheme is enough to select engine
- **Extensible**: Can add factory pattern later if dynamic selection needed

### Why Keep queryFutures in Engine?

**Alternative**: Keep `queryFutures` in `SurrealDB`, let engines just send/receive

**Chosen Approach**: Move `queryFutures` into engines

**Rationale**:
- **Engine-Specific**: gRPC doesn't need request/response matching
- **Encapsulation**: Each engine manages its own async state
- **Cleaner**: `SurrealDB` becomes pure API wrapper

## Implementation Plan

### Phase 1: Engine Abstraction (Current Phase)

1. ✅ Create `.ai/rpc-abstraction-design.md` (this document)
2. Create `src/surreal/private/engines/engine.nim`:
   - Define `RpcEngine` base type
   - Define core methods: `sendRequest`, `close`, `isConnected`
3. Create `src/surreal/private/engines/websocket_cbor.nim`:
   - Define `WebSocketCborEngine` type
   - Migrate connection logic from `logic/connection.nim`
   - Migrate RPC send logic from `queries/rpc.nim`
   - Migrate listen loop from `logic/listenLoop.nim`
4. Update `src/surreal/private/types/surrealdb.nim`:
   - Change `ws: WebSocket` to `engine: RpcEngine`
   - Remove `queryFutures` and `isConnected` fields
5. Update `src/surreal/private/queries/rpc.nim`:
   - Modify `sendRpc` to use `db.engine.sendRequest`
6. Update `src/surreal/private/logic/connection.nim`:
   - Implement engine selection based on URL scheme
   - Call appropriate engine constructor
7. Delete `src/surreal/private/logic/listenLoop.nim` (merged into engine)
8. Update `src/surrealdb.nim`:
   - Export engine types (optional, for advanced users)
9. Test with existing examples/tests

### Phase 2: gRPC Implementation (Future)

1. Add gRPC client library dependency
2. Generate Nim code from `.proto` files in [surrealdb-protocol](https://github.com/surrealdb/surrealdb-protocol)
3. Create `src/surreal/private/grpc/codec.nim`:
   - `SurrealValue` → Protobuf message conversion
   - Protobuf message → `SurrealValue` conversion
4. Create `src/surreal/private/engines/grpc_protobuf.nim`:
   - Define `GrpcProtobufEngine` type
   - Implement gRPC connection management
   - Implement method mapping (RpcMethod → gRPC service calls)
   - Implement response conversion
5. Update `newSurrealDbConnection` to handle `grpc://` and `grpcs://` schemes
6. Add gRPC-specific tests

### Phase 3: Advanced Features (Optional Future)

1. **Streaming Support**:
   ```nim
   method sendStreamingRequest*(
     engine: RpcEngine,
     methodName: string,
     params: seq[SurrealValue]
   ): Future[AsyncStream[SurrealValue]] {.base, async.}
   ```

2. **Connection Pooling**: Multiple engines for load balancing

3. **Engine Registry**: Dynamic engine selection for plugin architectures

4. **Mock Engine**: For testing without real connections

## Testing Strategy

### Unit Tests

- **Engine Interface**: Test base methods raise "not implemented"
- **WebSocketCborEngine**:
  - Mock WebSocket to test encoding/decoding
  - Test request/response matching
  - Test error handling
- **GrpcProtobufEngine** (future):
  - Mock gRPC client
  - Test method mapping
  - Test Protobuf conversion

### Integration Tests

- **Current**: Verify existing tests still pass after refactoring
- **Future**: Test against both WebSocket and gRPC SurrealDB instances

### Migration Testing

- **Compatibility**: Ensure all existing query methods work unchanged
- **API Stability**: Public API should not break

## Migration Path for Users

### Current Code (Before Refactoring)
```nim
import surrealdb

let db = await newSurrealDbConnection("ws://localhost:8000/rpc")
let result = await db.select("users")
db.disconnect()
```

### After Refactoring (No Changes Required!)
```nim
import surrealdb

let db = await newSurrealDbConnection("ws://localhost:8000/rpc")
let result = await db.select("users")
db.disconnect()
```

### With gRPC (Future)
```nim
import surrealdb

# Just change the URL scheme!
let db = await newSurrealDbConnection("grpc://localhost:9000")
let result = await db.select("users")
db.disconnect()
```

**Zero Breaking Changes**: The abstraction is completely transparent.

## Benefits Summary

### 1. Simplicity
- Single abstraction layer (RpcEngine)
- Uses Nim's built-in method dispatch
- No complex factory patterns or dependency injection

### 2. Clean Separation
- Transport + Protocol isolated in engines
- Business logic (queries) unchanged
- Type system (`SurrealValue`) unchanged

### 3. Extensibility
- Easy to add new engines (just inherit and override methods)
- Can add factory pattern later if needed
- Can add streaming without breaking existing code

### 4. User-Friendly
- Existing API completely unchanged
- Engine selection automatic (based on URL)
- Migration is just changing connection URL

### 5. Maintainability
- Clear responsibility boundaries
- Each engine self-contained
- Easy to test in isolation

## Risks and Mitigations

### Risk: Method Dispatch Performance
**Impact**: Low
**Mitigation**: Method dispatch is fast in Nim; RPC network overhead dominates

### Risk: Engine Abstraction Too Limiting
**Impact**: Medium
**Mitigation**: Can extend interface with additional methods; design is flexible

### Risk: gRPC Protocol Changes
**Impact**: Medium
**Mitigation**:
- Only WebSocketCborEngine implemented initially
- GrpcProtobufEngine waits for stable protocol
- Interface designed to accommodate streaming

### Risk: Breaking Changes During Migration
**Impact**: High (if occurs)
**Mitigation**:
- Comprehensive test coverage before refactoring
- Preserve all existing tests
- Public API remains unchanged

## References

- [SurrealDB.js Engine Abstraction](https://github.com/surrealdb/surrealdb.js/blob/f1809173e34fdea4d383ed3952df02dce6dbe037/packages/sdk/src/types/surreal.ts#L27)
- [SurrealDB gRPC Protocol (Protobuf)](https://github.com/surrealdb/surrealdb-protocol/tree/main/surrealdb/protocol)
- [SurrealDB gRPC Service Definition](https://github.com/surrealdb/surrealdb-protocol/blob/main/surrealdb/protocol/rpc/v1/rpc.proto)

## Conclusion

This design provides a clean, Nim-idiomatic abstraction that:
- Maintains API stability (zero breaking changes)
- Separates transport/protocol concerns into engines
- Supports both current (WebSocket/CBOR) and future (gRPC/Protobuf) protocols
- Remains simple without over-engineering

The implementation can proceed incrementally:
1. Refactor existing code into WebSocketCborEngine
2. Add GrpcProtobufEngine when protocol stabilizes
3. Users automatically benefit from new transports by changing URL scheme

**Status**: Ready for implementation ✅
