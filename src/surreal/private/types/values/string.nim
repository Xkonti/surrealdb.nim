proc toSurrealString*(value: string): SurrealValue =
    ## Converts a string to a SurrealString
    return SurrealValue(kind: SurrealString, stringVal: value)

proc toSurrealString*(value: seq[uint8]): SurrealValue =
    ## Converts a sequence of bytes to a SurrealString
    var text = cast[string](value)
    return SurrealValue(kind: SurrealString, stringVal: text)

proc toSurrealString*(value: openArray[uint8]): SurrealValue =
    ## Converts a sequence of bytes to a SurrealString
    var text = cast[string](value.toSeq)
    return SurrealValue(kind: SurrealString, stringVal: text)

proc `%%%`*(value: string): SurrealValue =
    ## Converts a sequence of bytes to a SurrealValue
    return toSurrealString(value)

proc getString*(value: SurrealValue): string =
    ## Extract the string value of a SurrealString.
    case value.kind
    of SurrealString:
        return value.stringVal
    else:
        raise newException(ValueError, "Cannot extract the string value from a $1 value" % $value.kind)