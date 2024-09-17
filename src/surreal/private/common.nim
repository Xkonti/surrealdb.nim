import std/[asyncdispatch, asyncfutures, json, strutils, tables]
import ./utils
import ../core
import ws

type
    # SupportedTypes* = enum
    #     SurrealNone,
    #     SurrealNull,
    #     SurrealString

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
        Run = "run"

# func getType*(x: NullType): SupportedTypes =
#     return SurrealNull

# func getType*(x: NoneType): SupportedTypes =
#     return SurrealNone

# func getType*(x: string): SupportedTypes =
#     return SurrealString

proc sendQuery*(db: SurrealDB, queryMethod: RpcMethod, params: string | JsonNode): Future[SurrealResult[JsonNode]] {.async.} =
    # Generate a new ID for the request - this is used to match the response with the request
    let queryId = getNextId()

    
    # Prep the request string
    # Avoid JSON errors if provided empty string
    var paramsString = $params
    if paramsString.len == 0:
        paramsString = "\"\""
    let queryString = """{"id": $1, "method": "$2", "params": $3}""" % [$queryId, $queryMethod, paramsString]

    # Create and register a new future for the request
    let future: FutureResponse = newFuture[SurrealResult[JsonNode]]("sendQuery '" & $queryMethod & "' #" & $queryId)
    db.queryFutures[queryId] = future

    # Attempt to send the request and return the result
    try:
        await db.ws.send(queryString)
        return await future

    # 👇 This is pure confusion 👇
    # If there was an error when sending the request, fail the future
    # There's a chance that the future itself failed when being awaited, but it's very unlikely
    except CatchableError as e:
        # Check if the future failed already
        if not future.failed:
            future.fail(e)
            echo "Error sending query #", queryId, ": ", e.msg
            # Make sure to remove the future from the table ASAP
            # As it's not possible to get a response for a query that wasn't sent
            db.queryFutures.del(queryId)
            future.fail(e)
            return await future

        echo "Failed to await future for query #", queryId, ": ", e.msg
        return await future