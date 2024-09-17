include shared_imports
import ../types/none

proc invalidate*(db: SurrealDB): Future[SurrealResult[NoneType]] {.async.} =
    ## Returns the record of an authenticated record user.
    let response = await db.sendRpc(RpcMethod.Invalidate, "")
    if response.isOk:
        return surrealResponse[NoneType](None)
    else:
        return err[NoneType, SurrealError](response.error)