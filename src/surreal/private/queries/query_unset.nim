include shared_imports
import ../types/none

# Remove the provided viariable from the current connection
proc unset*(db: SurrealDB, name: string): Future[SurrealResult[NoneType]] {.async.} =
    let response = await db.sendRpc(RpcMethod.Unset, %* [ name ])
    if response.isOk:
        return surrealResponse[NoneType](None)
    else:
        return err[NoneType, SurrealError](response.error)