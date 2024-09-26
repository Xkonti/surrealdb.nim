let surrealNull* = SurrealValue(kind: SurrealNull)
    ## A SurrealNull value representing null.

proc newSurrealNull*(): SurrealValue =
    ## Creates a new SurrealNull
    return surrealNull

proc toSurrealNull*(_: NullType): SurrealValue =
    ## Converts a null to a SurrealNull
    return surrealNull

proc `%%%`*(_: NullType): SurrealValue =
    ## Converts a null to a SurrealNull
    return surrealNull

proc toNull*(value: SurrealValue): NullType =
    ## Converts a SurrealNull to a null.
    if value.kind != SurrealNull:
        raise newException(ValueError, "Cannot convert a non-null value to a null")
    return Null

proc `==`*(a: SurrealValue, b: NullType): bool =
    ## Checks if the SurrealValue is equal to the Null.
    return a.kind == SurrealNull

proc `==`*(a: NullType, b: SurrealValue): bool =
    ## Checks if the SurrealValue is equal to the Null.
    return b.kind == SurrealNull