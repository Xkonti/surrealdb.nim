# surrealdb.nim

An unofficial SurrealDB driver for Nim.

> !WARNING!
> This is a very early version - things are barely tested and are subject to change.

You can follow the development of this library on:
- [YouTube livestreams](https://www.youtube.com/playlist?list=PL5AVzKSngnt-vUzv1ykgY8mToNWsMYdcG)
- [Twitch](https://www.twitch.tv/xkontitech)

## Support for RPC JSON methods

This is a list of methods implemented methods that take `JsonNode` or strings as inputs and return `JsonNode` as output. No _smart_ deserialization etc:

- [x] `use` method
- [x] `info` method
- [x] `version` method
- [x] `signup` method
- [x] `signin` method
- [x] `authenticate` method
- [x] `invalidate` method
- [x] `let` method
- [x] `unset` method
- [x] `query` method
- [x] `select` method
- [x] `create` method
- [x] `insert` method
- [x] `update` method
- [x] `upsert` method
- [x] `relate` method
- [x] `merge` method
- [x] `delete` method
- [x] `run` method

The following methods will be implemented after the CBOR-based RPC is implemented:

- [ ] `live` method
- [ ] `kill` method
- [ ] `patch` method
- [ ] `qraphql` method
- [ ] `queryRaw` method

## Next steps

- [ ] **Use CBOR instead of JSON for RPC requests** (in progress)
- [ ] Automatic marshalling of SurrealDB types to/from Nim types
- [ ] Various helpers for dealing with returned data