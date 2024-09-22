proc toSurrealString*(value: string): SurrealValue =
    ## Converts a string to a SurrealString
    return SurrealValue(kind: SurrealString, stringVal: value)

proc toSurrealString*(value: seq[uint8]): SurrealValue =
    ## Converts a sequence of bytes to a SurrealString
    var text = cast[string](value)
    return SurrealValue(kind: SurrealString, stringVal: text)

proc `%%%`*(value: string): SurrealValue =
    ## Converts a sequence of bytes to a SurrealValue
    return toSurrealString(value)

proc `$`*(value: SurrealValue): string =
    ## Converts a SurrealValue to a sequence of bytes.
    case value.kind
    of SurrealInteger:
        return $(value.toInt64)
    of SurrealBytes:
        return cast[string](value.bytesVal)
    of SurrealString:
        return value.stringVal
    else:
        raise newException(ValueError, "Cannot convert a {0} value to a string" % $value.kind)