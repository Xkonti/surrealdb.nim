proc len*(value: SurrealValue): int =
    ## Returns the length of the bytes array.
    case value.kind
    of SurrealArray:
        return value.arrayVal.len
    of SurrealBytes:
        return value.bytesVal.len
    of SurrealString:
        return value.stringVal.len
    of SurrealObject:
        return value.objectVal.len
    else:
        raise newException(ValueError, "Cannot get the length of a $1 value" % $value.kind)

proc toBytes*(value: SurrealValue): seq[uint8] =
    ## Converts a SurrealValue to a sequence of bytes.
    case value.kind
    of SurrealBytes:
        return value.bytesVal
    of SurrealString:
        return cast[seq[uint8]](value.stringVal)
    else:
        raise newException(ValueError, "Cannot convert a $1 value to a sequence of bytes" % $value.kind)

proc `$`*(value: SurrealValue): string =
    ## Converts a SurrealValue to a string representation - mostly for debugging purposes.
    case value.kind
    of SurrealInteger:
        return $(value.toInt64)
    of SurrealBytes:
        return cast[string](value.bytesVal)
    of SurrealString:
        return value.stringVal
    of SurrealArray:
        case value.arrayVal.len:
        of 0: return "[]"
        of 1: return "[" & $value.arrayVal[0] & "]"
        else:
            var text = "["
            for item in value.arrayVal:
                text = text & ", " & $item
            return text & "]"
    of SurrealObject:
        case value.objectVal.len:
        of 0: return "{}"
        of 1:
            let pair = value.objectVal.pairs.toSeq[0]
            return "{" & pair[0] & ": " & $pair[1] & "}"
        else:
            var text = "{"
            for pair in value.objectVal.pairs:
                text = text & ", " & pair[0] & ": " & $pair[1]
            return text & "}"
    else:
        raise newException(ValueError, "Cannot convert a {0} value to a string" % $value.kind)