include shared_imports
import ../types/[none]

proc `let`*(db: SurrealDB, name: string, value: SurrealValue): Future[SurrealResult[NoneType]] {.async.} =
    ## Set a variable for the current connection
    let response = await db.sendRpc(RpcMethod.Let, @[%%% name, value])
    if response.isOk:
        return surrealResponse[NoneType](None)
    else:
        return err[NoneType, SurrealError](response.error)


template `let`*(db: SurrealDB, name: string, value: untyped): untyped =
    ## Set a variable for the current connection
    db.let(name, %%* value)