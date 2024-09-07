import std/[asyncdispatch, asyncfutures, json, strutils, tables]
import ./core
import ./private/common
import ./private/utils


proc signin*(db: SurrealDB, user: string, pass: string): Future[JsonNode] {.async.} =
    # TODO: Add support for other parameters
    let params = %* [ { "user": user, "pass": pass } ]
    return await db.sendQuery(RpcMethod.Signin, params)


proc select*(db: SurrealDB, thing: string): Future[JsonNode] {.async.} =
    # TODO: Adhere to the RPC docs
    let params = %* [ thing ]
    return await db.sendQuery(RpcMethod.Select, params)