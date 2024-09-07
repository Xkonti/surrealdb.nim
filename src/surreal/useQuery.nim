import std/[asyncdispatch, json, strutils]
import ./core
import ./private/common
import ./private/utils

proc use*(db: SurrealDB, namespace: string, database: string) {.async.} =
    let queryId = getNextId()
    # TODO: Make sure to properly escape the namespace and database names - possibly using JSON serialization
    discard await db.sendQuery(queryId, RpcMethod.Use, """[ "$1", "$2" ]""" % [ namespace, database ])
    return