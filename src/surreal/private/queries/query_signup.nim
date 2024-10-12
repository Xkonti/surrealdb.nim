include shared_imports

proc signup*(
    db: SurrealDB,
    namespace: string, database: string, accessControl: string,
    params: SurrealValue
    ): Future[SurrealResult[string]] {.async.} =
        if params.kind != SurrealObject:
            raise newException(ValueError, "Expected SurrealObject for params")
        ## Sign up as a record user
        var params = params
        params["NS"] = namespace
        params["DB"] = database
        params["AC"] = accessControl
        let response = await db.sendRpc(RpcMethod.Signup, @[ params ])
        if response.isOk:
            return surrealResponse[string](response.ok.getString())
        else:
            return err[string, SurrealError](response.error)