import std/[asyncdispatch, json]
import ./core
import ./private/common

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
    user: string, pass: string,
    otherParams: varargs[JsonNode]
    ): Future[SurrealResult[string]] {.async.} =
        var params = %* { "NS": namespace, "DB": database, "AC": accessControl, "user": user, "pass": pass }
        for param in otherParams:
            params.add(param)
        params = %* [ params ]
        let response = await db.sendQuery(RpcMethod.Signin, params)
        if response.isOk:
            return surrealResponse[string](response.ok.getStr())
        else:
            return err[string, SurrealError](response.error)