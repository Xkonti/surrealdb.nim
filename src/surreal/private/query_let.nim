# Authenticate as with the given token.
proc `let`*(db: SurrealDB, name: string, value: SurQL): Future[SurrealResult[NoneType]] {.async.} =
    let response = await db.sendQuery(RpcMethod.Let, """["$1", $2]""" % [name, value.string])
    if response.isOk:
        return surrealResponse[NoneType](None)
    else:
        return err[NoneType, SurrealError](response.error)