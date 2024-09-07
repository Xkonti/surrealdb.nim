import std/[asyncdispatch, asyncfutures, json, strutils, tables]
import ./utils
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

proc sendQuery*(db: SurrealDB, queryMethod: RpcMethod, params: string | JsonNode): Future[JsonNode] {.async.} =
    let queryId = getNextId()
    let future: Future[JsonNode] = newFuture[JsonNode]("sendQuery '" & $queryMethod & "' #" & $queryId)
    # echo "Create a future for query ID: ", queryId
    let queryString = """{"id": $1, "method": "$2", "params": $3}""" % [$queryId, $queryMethod, $params]
    try:
        db.queryFutures[queryId] = future
        # echo "Added future for query ID: ", queryId
        await db.ws.send(queryString)
        # echo "Sent query ID: ", queryId
    except CatchableError as e:
        echo "Error sending query #", queryId, ": ", e.msg
        future.fail(e)
        # Make sure to remove the future from the table
        # As it's not possible to get a response for a query that wasn't sent
        db.queryFutures.del(queryId)
    finally:
        # echo "Awaiting the future for query ID: ", queryId
        return await future