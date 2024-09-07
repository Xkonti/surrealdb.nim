import std/[asyncdispatch, json, options, strutils]
import ./core
import ./private/common

#[

All possible use cases:

[none, none]     -- Won't change ns or db ❌ Not supported in JSON
["test", none]   -- Change ns to test ✅ useNamespace(namespace: string)
[none, "test"]   -- Change db to test ❌ Not supported in JSON
["test", "test"] -- Change ns and db to test ✅ use(namespace: string, database: string)

[none, null]     -- Will only unset the database ❌ Not supported in JSON
[null, none]     -- Will throw an error, you cannot unset only the namespace ❌ Not supported in JSON
[null, null]     -- Will unset both ns and db ✅ useNamespace(namespace: nil) - this will also unset the database
["test", null]   -- Change ns to test and unset db ✅ use(namespace: string, database: nil)

TODO: When implementing the CBOR serializer, make sure to support the `none` value
This is not supported by the JSON serializer as is doen't have a way to represent `none` values.
Only `null` is supported.

]#

## Use the namespace and database specified by the given parameters
proc use*(db: SurrealDB, namespace: string, database: string) {.async.} =
    # TODO: Make sure to properly escape the namespace and database names - possibly using JSON serialization
    discard await db.sendQuery(RpcMethod.Use, """[ "$1", "$2" ]""" % [ namespace, database ])

## Use the namespace and database specified by the given parameters.
## If the database is not specified, it will be unset.
proc use*(db: SurrealDB, namespace: string, database: NullType) {.async.} =
    discard await db.sendQuery(RpcMethod.Use, """[ "$1", null ]""" % [ namespace ])

## Use the namespace specified by the given parameter. This unsets the database.
proc useNamespace*(db: SurrealDB, namespace: string) {.async.} =
    # TODO: Make sure to properly escape the namespace - possibly using JSON serialization
    discard await db.sendQuery(RpcMethod.Use, """[ "$1", null ]""" % [ namespace ])

## Unset the namespace. This will also unset the database.
proc useNamespace*(db: SurrealDB, namespace: NullType) {.async.} =
    discard await db.sendQuery(RpcMethod.Use, "[ null, null ]")
