include shared_imports

# TODO: Response always returns a token - even for system users

# Sign in as a root user
proc signin*(
    db: SurrealDB,
    user: string, pass: string
    ): Future[SurrealResult[string]] {.async.} =
        let params = %* [ { "user": user, "pass": pass } ]
        let response = await db.sendQuery(RpcMethod.Signin, params)
        if response.isOk:
            return surrealResponse[string](response.ok.getStr())
        else:
            return err[string, SurrealError](response.error)

# Sign in as a namespace user
proc signin*(
    db: SurrealDB,
    namespace: string,
    user: string, pass: string
    ): Future[SurrealResult[string]] {.async.} =
        let params = %* [ { "NS": namespace, "user": user, "pass": pass } ]
        let response = await db.sendQuery(RpcMethod.Signin, params)
        if response.isOk:
            return surrealResponse[string](response.ok.getStr())
        else:
            return err[string, SurrealError](response.error)

# Sign in as a database user
proc signin*(
    db: SurrealDB,
    namespace: string, database: string,
    user: string, pass: string
    ): Future[SurrealResult[string]] {.async.} =
        let params = %* [ { "NS": namespace, "DB": database, "user": user, "pass": pass } ]
        let response = await db.sendQuery(RpcMethod.Signin, params)
        if response.isOk:
            return surrealResponse[string](response.ok.getStr())
        else:
            return err[string, SurrealError](response.error)

# Sign in as a record user
proc signin*(
    db: SurrealDB,
    namespace: string, database: string, accessControl: string,
    params: QueryParams
    ): Future[SurrealResult[string]] {.async.} =
        var params = params
        params["NS"] = namespace
        params["DB"] = database
        params["AC"] = accessControl
        echo "Params: ", params
        let response = await db.sendQuery(RpcMethod.Signin, %* [ params ])
        if response.isOk:
            return surrealResponse[string](response.ok.getStr())
        else:
            return err[string, SurrealError](response.error)