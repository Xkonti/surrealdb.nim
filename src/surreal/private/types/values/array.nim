proc newSurrealArray*(): SurrealValue =
    ## Creates a new SurrealArray
    return SurrealValue(kind: SurrealArray, arrayVal: @[])

proc toSurrealArray*(value: seq[SurrealValue]): SurrealValue =
    ## Converts a sequence of SurrealValues to a SurrealArray
    return SurrealValue(kind: SurrealArray, arrayVal: value)

proc toSurrealArray*(value: openArray[SurrealValue]): SurrealValue =
    ## Converts a sequence of SurrealValues to a SurrealArray
    return SurrealValue(kind: SurrealArray, arrayVal: value.toSeq)

proc `%%%`*(value: seq[SurrealValue]): SurrealValue =
    ## Converts a sequence of SurrealValues to a SurrealArray
    return toSurrealArray(value)

proc `%%%`*(value: openArray[SurrealValue]): SurrealValue =
    ## Converts a sequence of SurrealValues to a SurrealArray
    return toSurrealArray(value)

proc getSeq*(value: SurrealValue): seq[SurrealValue] =
    ## Converts a SurrealValue to a sequence of SurrealValues.
    case value.kind
    of SurrealArray:
        return value.arrayVal
    else:
        raise newException(ValueError, "Cannot convert a {0} value to a sequence of SurrealValues" % $value.kind)


proc add*(value: var SurrealValue, items: varargs[SurrealValue, `%%%`]) =
    ## Adds values to the array.
    case value.kind
    of SurrealArray:
        value.arrayVal.add(items)
    else:
        raise newException(ValueError, "Cannot add values to a {0} value" % $value.kind)
