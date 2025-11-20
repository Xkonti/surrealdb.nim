# SurrealDB.nim

An unofficial SurrealDB driver for Nim.

> [!WARNING]
> This is a very early version - things are barely tested and are subject to change.

## ⚒️ Current development status

Gathering documentation on gRPC protocol - the library will be rewritten to use gRPC instead of CBOR and then the goal is to implement full SurrealDB 3.0 support.

This will change the API of the library drastically.

You can follow the development of this library on:
- [YouTube livestreams](https://www.youtube.com/playlist?list=PL5AVzKSngnt-vUzv1ykgY8mToNWsMYdcG)
- [Twitch](https://www.twitch.tv/xkontitech)

## Installation

You can install this library using Nimble:

```bash
nimble install surrealdb
```

or by adding it to your `nimble` file:

```nim
requires "surrealdb >= 0.1.0"
```

## ▶️ Usage example

```nim
import surrealdb

proc main() {.async.} =
    # Connect to SurrealDB
    let surreal = await newSurrealDbConnection(ws://localhost:1234/rpc)

    # Disconnect from SurrealDB afterwards
    defer: surreal.disconnect()

    # Switch to the test database
    let ns = "test"
    let db = "test"
    let useResponse = await surreal.use(ns, db)
    # Responses allow to call `.isOk` to check if the request was successful
    assert useResponse.isOk

    # Sign in as root user
    let signinResponse = await surreal.signin("rootuser", "somepassword")
    if not signinResponse.isOk:
        # You can also access the error message if the database returned an error
        echo "Signin error: ", signinResponse.error.message
        quit(1)

    # Query the database
    # The `surql` string literal creates a distinct string of type `SurQL`
    let queryResponse = await surreal.query(surql"SELECT * FROM users")

    if queryResponse.isOk:
        # Print out the result
        # The `ok` field contains the result of the query
        # The results is a JSON array with a result-per-query
        echo "Query result: ", queryResponse.ok[0]["result"]

    # The `rc` string literal creates a new RecordID object
    let selectResponse = await surreal.select(rc"users:12345")

    # The `tb` string literal creates a new TableName object
    let tableResponse = await surreal.select(tb"users")

waitFor main()
```

## ✅ Support for RPC JSON methods

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

The following methods are still not implemented:

- [ ] `live` method
- [ ] `kill` method
- [ ] `patch` method
- [ ] `qraphql` method
- [ ] `queryRaw` method

## ⏳ Next steps

- [ ] **gRPC protocol implementation** (in progress)
- [ ] Automatic marshalling of SurrealDB types to/from Nim types
- [ ] Various helpers for dealing with returned data
- [ ] Automated testing via GitHub Actions that run SurrealDB in docker containers

## Contributing

We welcome contributions to SurrealDB.nim! If you're interested in helping improve this SurrealDB driver for Nim, please take a look at our [Contributing Guidelines](CONTRIBUTING.md) for more information on how to get started.

Your contributions, whether they're bug reports, feature requests, or code changes, are greatly appreciated. Together, we can make SurrealDB.nim even better!
