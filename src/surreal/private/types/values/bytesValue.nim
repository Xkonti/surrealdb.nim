proc toSurrealBytes*(value: seq[uint8]): SurrealValue =
    ## Converts a sequence of bytes to a SurrealValue
    return SurrealValue(kind: SurrealBytes, bytesVal: value)

proc toSurrealBytes*(value: string): SurrealValue =
    ## Converts a string to a SurrealValue
    return SurrealValue(kind: SurrealBytes, bytesVal: cast[seq[uint8]](value))

proc `%%%`*(value: seq[uint8]): SurrealValue =
    ## Converts a sequence of bytes to a SurrealValue
    return toSurrealBytes(value)

proc bytes*(value: SurrealValue): seq[uint8] =
    ## Converts bytes array from SurrealBytes
    case value.kind
    of SurrealBytes:
        return value.bytesVal
    else:
        raise newException(ValueError, "The value is of type $1 and doesn't contain raw bytes" % $value.kind)

proc toBytes*(value: SurrealValue): seq[uint8] =
    ## Converts a SurrealValue to a sequence of bytes.
    case value.kind
    of SurrealBytes:
        return value.bytesVal
    of SurrealString:
        return cast[seq[uint8]](value.stringVal)
    else:
        raise newException(ValueError, "Cannot convert a $1 value to a sequence of bytes" % $value.kind)