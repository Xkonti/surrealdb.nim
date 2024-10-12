include shared_imports

proc signin*(
    db: SurrealDB,
    user: string, pass: string
    ): Future[SurrealResult[string]] {.async.} =
        ## Sign in as a root user
        let params: seq[SurrealValue] = @[ %%* { "user": user, "pass": pass } ]
        let response = await db.sendRpc(RpcMethod.Signin, params)
        if response.isOk:
            return surrealResponse[string](response.ok.getString())
        else:
            return err[string, SurrealError](response.error)

proc signin*(
    db: SurrealDB,
    namespace: string,
    user: string, pass: string
    ): Future[SurrealResult[string]] {.async.} =
        ## Sign in as a namespace user
        let params: seq[SurrealValue] = @[ %%* { "NS": namespace, "user": user, "pass": pass } ]
        let response = await db.sendRpc(RpcMethod.Signin, params)
        if response.isOk:
            return surrealResponse[string](response.ok.getString())
        else:
            return err[string, SurrealError](response.error)

proc signin*(
    db: SurrealDB,
    namespace: string, database: string,
    user: string, pass: string
    ): Future[SurrealResult[string]] {.async.} =
        ## Sign in as a database user
        let params: seq[SurrealValue] = @[ %%* { "NS": namespace, "DB": database, "user": user, "pass": pass } ]
        let response = await db.sendRpc(RpcMethod.Signin, params)
        if response.isOk:
            return surrealResponse[string](response.ok.getString())
        else:
            return err[string, SurrealError](response.error)

proc signin*(
        db: SurrealDB,
        namespace: string, database: string, accessControl: string,
        params: SurrealValue
        ): Future[SurrealResult[string]] {.async.} =
    ## Sign in as a record user
    if params.kind != SurrealObject:
        raise newException(ValueError, "Expected SurrealObject for params")
    var params = params
    params["NS"] = namespace
    params["DB"] = database
    params["AC"] = accessControl
    let response = await db.sendRpc(RpcMethod.Signin, @[ params ])
    if response.isOk:
        return surrealResponse[string](response.ok.getString())
    else:
        return err[string, SurrealError](response.error)

template signin*(
        db: SurrealDB,
        namespace: string, database: string, accessControl: string,
        params: untyped
        ): untyped =
    ## Sign in as a record user
    db.signin(namespace, database, accessControl, %%* params)