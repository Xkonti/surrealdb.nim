let surrealNone* = SurrealValue(kind: SurrealNone)
    ## A SurrealNone value representing none.

proc newSurrealNone*(): SurrealValue =
    ## Creates a new SurrealNone
    return surrealNone

proc toSurrealNone*(_: NoneType): SurrealValue =
    ## Converts a none to a SurrealNone
    return surrealNone

proc `%%%`*(_: NoneType): SurrealValue =
    ## Converts a none to a SurrealNone
    return surrealNone

proc toNone*(value: SurrealValue): NoneType =
    ## Converts a SurrealNone to a none.
    if value.kind != SurrealNone:
        raise newException(ValueError, "Cannot convert a non-none value to a none")
    return None

proc `==`*(a: SurrealValue, b: NoneType): bool =
    ## Checks if the SurrealValue is equal to the None.
    return a.kind == SurrealNone

proc `==`*(a: NoneType, b: SurrealValue): bool =
    ## Checks if the SurrealValue is equal to the None.
    return b.kind == SurrealNone