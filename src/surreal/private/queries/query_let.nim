include shared_imports
import ../types/[none, surql]

# Set a variable for the current connection
proc `let`*(db: SurrealDB, name: string, value: SurQL): Future[SurrealResult[NoneType]] {.async.} =
    let response = await db.sendRpc(RpcMethod.Let, """["$1", $2]""" % [name, value.string])
    if response.isOk:
        return surrealResponse[NoneType](None)
    else:
        return err[NoneType, SurrealError](response.error)