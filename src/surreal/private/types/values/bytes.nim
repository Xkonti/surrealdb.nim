proc toSurrealBytes*(value: seq[uint8]): SurrealValue =
    ## Converts a sequence of bytes to a SurrealValue
    return SurrealValue(kind: SurrealBytes, bytesVal: value)

proc toSurrealBytes*(value: openArray[uint8]): SurrealValue =
    ## Converts a sequence of bytes to a SurrealValue
    return SurrealValue(kind: SurrealBytes, bytesVal: value.toSeq)

proc toSurrealBytes*(value: string): SurrealValue =
    ## Converts a string to a SurrealValue
    return SurrealValue(kind: SurrealBytes, bytesVal: cast[seq[uint8]](value))

proc `%%%`*(value: seq[uint8]): SurrealValue =
    ## Converts a sequence of bytes to a SurrealValue
    return toSurrealBytes(value)

proc `%%%`*(value: openArray[uint8]): SurrealValue =
    ## Converts a sequence of bytes to a SurrealValue
    return toSurrealBytes(value)

proc bytes*(value: SurrealValue): seq[uint8] =
    ## Converts bytes array from SurrealBytes
    case value.kind
    of SurrealBytes:
        return value.bytesVal
    else:
        raise newException(ValueError, "The value is of type $1 and doesn't contain raw bytes" % $value.kind)