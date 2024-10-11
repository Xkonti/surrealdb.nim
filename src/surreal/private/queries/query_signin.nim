include shared_imports

# TODO: Response always returns a token - even for system users

proc signin*(
    db: SurrealDB,
    user: string, pass: string
    ): Future[SurrealResult[string]] {.async.} =
        ## Sign in as a root user
        let params: seq[SurrealValue] = @[ %%% { "user": %%% user, "pass": %%% pass } ]
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
        let params: seq[SurrealValue] = @[ %%% { "NS": %%% namespace, "user": %%% user, "pass": %%% pass } ]
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
        let params: seq[SurrealValue] = @[ %%% { "NS": %%% namespace, "DB": %%% database, "user": %%% user, "pass": %%% pass } ]
        let response = await db.sendRpc(RpcMethod.Signin, params)
        if response.isOk:
            return surrealResponse[string](response.ok.getString())
        else:
            return err[string, SurrealError](response.error)

proc signin*(
    db: SurrealDB,
    namespace: string, database: string, accessControl: string,
    params: varargs[SurrealObjectEntry]
    ): Future[SurrealResult[string]] {.async.} =
        ## Sign in as a record user
        var data = newSurrealObject()
        data["NS"] = %%% namespace
        data["DB"] = %%% database
        data["AC"] = %%% accessControl
        # echo "Params: ", params
        let response = await db.sendRpc(RpcMethod.Signin, @[ data ])
        if response.isOk:
            return surrealResponse[string](response.ok.getString())
        else:
            return err[string, SurrealError](response.error)