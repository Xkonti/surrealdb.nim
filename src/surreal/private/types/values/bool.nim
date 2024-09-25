let surrealTrue* = SurrealValue(kind: SurrealBool, boolVal: true)
    ## A SurrealBool value representing true.

let surrealFalse* = SurrealValue(kind: SurrealBool, boolVal: false)
    ## A SurrealBool value representing false.

proc toSurrealBool*(value: bool): SurrealValue =
    ## Converts a bool to a SurrealBool
    return if value: surrealTrue else: surrealFalse

proc `%%%`*(value: bool): SurrealValue =
    ## Converts a bool to a SurrealBool
    return if value: surrealTrue else: surrealFalse

proc `not`*(value: SurrealValue): SurrealValue =
    ## Negates the SurrealBool value.
    case value.kind
    of SurrealBool:
        if value.boolVal:
            return surrealFalse
        else:
            return surrealTrue
    else:
        raise newException(ValueError, "Cannot negate a $1 value" % $value.kind)

proc getBool*(value: SurrealValue): bool =
    ## Extracts the bool value from the SurrealBool.
    case value.kind
    of SurrealBool:
        return value.boolVal
    else:
        raise newException(ValueError, "Cannot extract the bool value from a $1 value" % $value.kind)
