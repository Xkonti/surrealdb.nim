include shared_imports
import ../types/none

# Authenticate as with the given token.
proc authenticate*(db: SurrealDB, token: string): Future[SurrealResult[NoneType]] {.async.} =
    let response = await db.sendRpc(RpcMethod.Authenticate, %* [ token ])
    if response.isOk:
        return surrealResponse[NoneType](None)
    else:
        return err[NoneType, SurrealError](response.error)