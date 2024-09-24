proc len*(value: SurrealValue): int =
    ## Returns the length of the bytes array.
    case value.kind
    of SurrealArray:
        return value.arrayVal.len
    of SurrealBytes:
        return value.bytesVal.len
    of SurrealString:
        return value.stringVal.len
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