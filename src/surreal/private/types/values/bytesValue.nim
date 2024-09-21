proc toSurrealBytes*(value: seq[uint8]): SurrealValue =
    ## Converts a sequence of bytes to a SurrealValue
    return SurrealValue(kind: SurrealBytes, bytesVal: value)

proc `%%%`*(value: seq[uint8]): SurrealValue =
    ## Converts a sequence of bytes to a SurrealValue
    return toSurrealBytes(value)

proc toBytes*(value: SurrealValue): seq[uint8] =
    ## Converts a SurrealValue to a sequence of bytes.
    if value.kind != SurrealBytes:
        raise newException(ValueError, "Cannot convert a non-bytes value to a sequence of bytes")
    return value.bytesVal