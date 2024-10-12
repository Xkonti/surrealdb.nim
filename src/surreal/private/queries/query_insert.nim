include shared_imports

proc insert_bulk(db: SurrealDB, table: TableName | RecordId, contents: SurrealValue): Future[SurrealResult[SurrealValue]] {.async.} =
    ## Insert multiple record into the specified table
    if contents.kind != SurrealArray:
        raise newException(ValueError, "Expected SurrealArray for contents")
    if contents.len == 0:
        raise newException(ValueError, "Expected at least one SurrealValue for contents")
    return await db.sendRpc(RpcMethod.Insert, @[ %%% table, contents ])

proc insert*(db: SurrealDB, table: TableName | RecordId, contents: SurrealValue): Future[SurrealResult[SurrealValue]] =
    ## Insert record/records into the specified table
    # This wrapper makes sure that varargs are converted to a sequence as async procs can't handle varargs
    case contents.kind
    of SurrealObject:
        return insert_bulk(db, table, @[contents].toSurrealArray())
    of SurrealArray:
        return insert_bulk(db, table, contents)
    else:
        raise newException(ValueError, "Expected SurrealObject or SurrealArray for contents")

# TODO: Why does this not work?
# template insert*(db: SurrealDB, table: TableName | RecordId, contents: untyped): untyped =
#     ## Insert multiple record into the specified table
#     # This is a convenience template that allows you to skip the `%%*` operator.
#     db.insert(table, %%* contents)
