include shared_imports

# TODO: Response always returns a token - even for system users

proc signin*(
    db: SurrealDB,
    user: string, pass: string
    ): Future[SurrealResult[string]] {.async.} =
        ## Sign in as a root user
        let params = %* [ { "user": user, "pass": pass } ]
        let response = await db.sendRpc(RpcMethod.Signin, params)
        if response.isOk:
            return surrealResponse[string](response.ok.getStr())
        else:
            return err[string, SurrealError](response.error)

proc signin*(
    db: SurrealDB,
    namespace: string,
    user: string, pass: string
    ): Future[SurrealResult[string]] {.async.} =
        ## Sign in as a namespace user
        let params = %* [ { "NS": namespace, "user": user, "pass": pass } ]
        let response = await db.sendRpc(RpcMethod.Signin, params)
        if response.isOk:
            return surrealResponse[string](response.ok.getStr())
        else:
            return err[string, SurrealError](response.error)

proc signin*(
    db: SurrealDB,
    namespace: string, database: string,
    user: string, pass: string
    ): Future[SurrealResult[string]] {.async.} =
        ## Sign in as a database user
        let params = %* [ { "NS": namespace, "DB": database, "user": user, "pass": pass } ]
        let response = await db.sendRpc(RpcMethod.Signin, params)
        if response.isOk:
            return surrealResponse[string](response.ok.getStr())
        else:
            return err[string, SurrealError](response.error)

proc signin*(
    db: SurrealDB,
    namespace: string, database: string, accessControl: string,
    params: QueryParams
    ): Future[SurrealResult[string]] {.async.} =
        ## Sign in as a record user
        var params = params
        params["NS"] = namespace
        params["DB"] = database
        params["AC"] = accessControl
        echo "Params: ", params
        let response = await db.sendRpc(RpcMethod.Signin, %* [ params ])
        if response.isOk:
            return surrealResponse[string](response.ok.getStr())
        else:
            return err[string, SurrealError](response.error)