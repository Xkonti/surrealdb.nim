# SurrealDB.nim

An unofficial SurrealDB driver for Nim.

> !WARNING!
> This is a very early version - things are barely tested and are subject to change.

## ⚒️ Current development status

Currently, the CBOR protocol is being implemented, which will lead to:
- Improved performance
- Support for easier ways to specify query parameters with specific types of values
- Support for receiving responses that contain type information

This will change the API of the library drastically.

You can follow the development of this library on:
- [YouTube livestreams](https://www.youtube.com/playlist?list=PL5AVzKSngnt-vUzv1ykgY8mToNWsMYdcG)
- [Twitch](https://www.twitch.tv/xkontitech)

## Insstalllation

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

The following methods will be implemented after the CBOR-based RPC is implemented:

- [ ] `live` method
- [ ] `kill` method
- [ ] `patch` method
- [ ] `qraphql` method
- [ ] `queryRaw` method

## ⏳ Next steps

- [ ] **Use CBOR instead of JSON for RPC requests** (in progress)
- [ ] Automatic marshalling of SurrealDB types to/from Nim types
- [ ] Various helpers for dealing with returned data
- [ ] Automated testing via GitHub Actions that run SurrealDB in docker containers