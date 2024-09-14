import std/[asyncdispatch, asyncfutures, json, strutils, tables]
import ./core
import ./private/common
import ./private/utils

include ./private/query_use
include ./private/query_info
include ./private/query_signup
include ./private/query_signin
include ./private/query_authenticate
include ./private/query_invalidate
include ./private/query_let
include ./private/query_unset
# TODO: ./private/query_live
# TODO: ./private/query_kill
include ./private/query_query

proc select*(db: SurrealDB, thing: string): Future[SurrealResult[JsonNode]] {.async.} =
    # TODO: Adhere to the RPC docs
    let params = %* [ thing ]
    return await db.sendQuery(RpcMethod.Select, params)