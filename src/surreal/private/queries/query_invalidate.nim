include shared_imports
import ../types/none

proc invalidate*(db: SurrealDB): Future[SurrealResult[NoneType]] {.async.} =
    ## Invalidates the user’s session for the current connection
    let response = await db.sendRpc(RpcMethod.Invalidate, @[])
    if response.isOk:
        return surrealResponse[NoneType](None)
    else:
        return err[NoneType, SurrealError](response.error)