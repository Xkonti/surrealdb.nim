import std/[asyncdispatch, asyncfutures, json, strutils, tables]
import ../core
import ws

type
    ## Names of RPC methods supported by SurrealDB
    RpcMethod* = enum
        Use = "use"
        Info = "info"
        Signup = "signup"
        Signin = "signin"
        Authenticate = "authenticate"
        Invalidate = "invalidate"
        Let = "let"
        Unset = "unset"
        Live = "live"
        Kill = "kill"
        Query = "query"
        Select = "select"
        Create = "create"
        Insert = "insert"
        Update = "update"
        Upsert = "upsert"
        Relate = "relate"
        Merge = "merge"
        Patch = "patch"
        Delete = "delete"

    ## The common RPC request shape
    # RpcRequest* = object
    #     id*: int
    #     `method`*: RpcMethod
    #     params*: JsonNode[] | string
    
    ## The common RPC response shape
    RpcResponse* = object
        id*: int
        result*: JsonNode

proc sendQuery*(db: SurrealDB, queryId: int, queryMethod: RpcMethod, params: string | JsonNode): Future[JsonNode] {.async.} =
    let future: Future[JsonNode] = newFuture[JsonNode]("sendQuery '" & $queryMethod & "' #" & $queryId)
    let queryString = """{"id": $1, "method": "$2", "params": $3}""" % [$queryId, $queryMethod, $params]
    try:
        await db.ws.send(queryString)
        db.queryFutures[queryId] = future
    except CatchableError as e:
        echo "Error sending query #", queryId, ": ", e.msg
        future.fail(e)
    finally:
        return await future