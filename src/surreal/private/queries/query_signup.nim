include shared_imports

# Sign up as a record user
proc signup*(
    db: SurrealDB,
    namespace: string, database: string, accessControl: string,
    params: QueryParams
    ): Future[SurrealResult[string]] {.async.} =
        var params = params
        params["NS"] = namespace
        params["DB"] = database
        params["AC"] = accessControl
        echo "Params: ", params
        let response = await db.sendRpc(RpcMethod.Signup, %* [ params ])
        if response.isOk:
            return surrealResponse[string](response.ok.getStr())
        else:
            return err[string, SurrealError](response.error)