
# Returns the record of an authenticated record user.
proc invalidate*(db: SurrealDB): Future[SurrealResult[NoneType]] {.async.} =
    let response = await db.sendQuery(RpcMethod.Invalidate, "")
    if response.isOk:
        return surrealResponse[NoneType](None)
    else:
        return err[NoneType, SurrealError](response.error)