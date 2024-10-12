include shared_imports
import ../types/none

proc authenticate*(db: SurrealDB, token: string): Future[SurrealResult[NoneType]] {.async.} =
    ## Authenticate with the given token.
    let response = await db.sendRpc(RpcMethod.Authenticate, @[ %%% token ])
    if response.isOk:
        return surrealResponse[NoneType](None)
    else:
        return err[NoneType, SurrealError](response.error)