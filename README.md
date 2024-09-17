# surreal
SurrealDB driver for Nim.

# TODOs

## Support for RPC JSON methods

This is a list of methods to create that take `JsonNode` or strings as inputs and return `JsonNode` as output. No _smart_ deserialization etc.

- [x] `use` method
- [x] `info` method
- [x] `version` method
- [x] `signup` method
- [x] `signin` method
- [x] `authenticate` method
- [x] `invalidate` method
- [x] `let` method
- [x] `unset` method
- [ ] `live` method
- [ ] `kill` method
- [x] `query` method
- [x] `select` method
- [x] `create` method
- [x] `insert` method
- [x] `update` method
- [x] `upsert` method
- [x] `relate` method
- [x] `merge` method
- [ ] `patch` method
- [x] `delete` method
- [x] `run` method
- [ ] `qraphql` method
- [ ] `queryRaw` method

## Nim-specific integration

- [ ] utilize generics for parameters of RPC methods
- [ ] utilize generics for return types of RPC methods
- [ ] helpers for extracting returned data

## In the future

- [ ] Switch to RPC CBOR to increase performance and support `none` values