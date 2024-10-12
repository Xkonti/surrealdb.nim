include shared_imports
include ../types/none

# TODO: Allow passing multiple records to in and out
# TODO: Allow passing data as a fourth parameter

proc relate*(db: SurrealDB, `in`: RecordId | SurrealValue, relation: TableName | SurrealValue, `out`: RecordId | SurrealValue, data: SurrealValue | NoneType = None): Future[SurrealResult[SurrealValue]] {.async.} =
    ## Relates records with a specified relation. Both `in` and `out` can be either a single RecordID,
    ## single SurrealRecordId or a Surreal Array of RecordIDs. Data is optional.
    let inValue: SurrealValue = when `in` is RecordId: %%% `in` else: `in`
    let outValue: SurrealValue = when `out` is RecordId: %%% `out` else: `out`

    if inValue.kind != SurrealRecordId and inValue.kind != SurrealArray:
        raise newException(ValueError, "Expected SurrealRecordId or SurrealArray for `in`")
    if outValue.kind != SurrealRecordId and outValue.kind != SurrealArray:
        raise newException(ValueError, "Expected SurrealRecordId or SurrealArray for `out`")

    when data is NoneType:
        return await db.sendRpc(RpcMethod.Relate, @[ inValue, %%% relation, outValue ])
    else:
        if data.kind != SurrealObject:
            raise newException(ValueError, "Expected SurrealObject for data")
        return await db.sendRpc(RpcMethod.Relate, @[ inValue, %%% relation, outValue, data ])
