proc toSurrealArray*(value: seq[SurrealValue]): SurrealValue =
    ## Converts a sequence of SurrealValues to a SurrealArray
    return SurrealValue(kind: SurrealArray, arrayVal: value)

proc `%%%`*(value: seq[SurrealValue]): SurrealValue =
    ## Converts a sequence of SurrealValues to a SurrealArray
    return toSurrealArray(value)

proc toSeq*(value: SurrealValue): seq[SurrealValue] =
    ## Converts a SurrealValue to a sequence of SurrealValues.
    case value.kind
    of SurrealArray:
        return value.arrayVal
    else:
        raise newException(ValueError, "Cannot convert a {0} value to a sequence of SurrealValues" % $value.kind)
