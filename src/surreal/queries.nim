import std/[asyncdispatch, asyncfutures, json, strutils, tables]
import ./core
import ./private/common
import ./private/utils


proc select*(db: SurrealDB, thing: string): Future[SurrealResult] {.async.} =
    # TODO: Adhere to the RPC docs
    let params = %* [ thing ]
    return await db.sendQuery(RpcMethod.Select, params)