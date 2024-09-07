# surreal
SurrealDB driver for Nim.

# TODOs

## Support for RPC methods

This is a list of methods to create that take `JsonNode` or strings as inputs and return `JsonNode` as output. No _smart_ deserialization etc.

- [ ] `use` method
- [ ] `info` method
- [ ] `signup` method
- [ ] `signin` method
- [ ] `authenticate` method
- [ ] `invalidate` method
- [ ] `let` method
- [ ] `unset` method
- [ ] `live` method
- [ ] `kill` method
- [ ] `query` method
- [ ] `select` method
- [ ] `create` method
- [ ] `insert` method
- [ ] `update` method
- [ ] `upsert` method
- [ ] `relate` method
- [ ] `merge` method
- [ ] `patch` method
- [ ] `delete` method

## Nim-specific integration

- [ ] utilize generics for parameters of RPC methods
- [ ] utilize generics for return types of RPC methods
- [ ] helpers for extracting returned data