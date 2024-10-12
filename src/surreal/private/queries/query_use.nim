include shared_imports
import ../types/[none, null]

proc use*(
        db: SurrealDB,
        namespace: string | NoneType | NullType,
        database: string | NoneType | NullType
        ): Future[SurrealResult[NoneType]] {.async.} =
    ## Use the namespace and database specified by the given parameters
    ##   NS    DB
    ## [none, none]     -- Won't change ns or db
    ## ["test", none]   -- Change ns to test
    ## [none, "test"]   -- Change db to test
    ## ["test", "test"] -- Change ns and db to test
    ## [none, null]     -- Will only unset the database
    ## [null, none]     -- Will throw an error, you cannot unset only the database
    ## [null, null]     -- Will unset both ns and db
    ## ["test", null]   -- Change ns to test and unset db
    # TODO: Make sure to properly escape the namespace and database names - possibly using JSON serialization
    let response = await db.sendRpc(RpcMethod.Use, @[ %%% namespace, %%% database ])
    if response.isOk:
        return surrealResponse[NoneType](None)
    else:
        return err[NoneType, SurrealError](response.error)