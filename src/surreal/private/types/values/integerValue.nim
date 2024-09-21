proc toSurrealInt*(value: uint | uint8 | uint16 | uint32 | uint64): SurrealValue =
    ## Converts an integer to a SurrealValue
    return SurrealValue(kind: SurrealInteger, intVal: value.uint64, intIsNegative: false)

proc toSurrealNegativeInt*(value: uint | uint8 | uint16 | uint32 | uint64): SurrealValue =
    ## Converts an integer to a SurrealValue
    return SurrealValue(kind: SurrealInteger, intVal: value.uint64, intIsNegative: true)

proc toSurrealInt*(value: int | int8 | int16 | int32 | int64): SurrealValue =
    ## Converts an integer to a SurrealValue
    if value < 0:
        return SurrealValue(kind: SurrealInteger, intVal: (-value).uint64, intIsNegative: true)
    return SurrealValue(kind: SurrealInteger, intVal: value.uint64, intIsNegative: false)

proc `%%%`*(value: uint | uint8 | uint16 | uint32 | uint64): SurrealValue =
    ## Converts an integer to a SurrealValue
    return toSurrealInt(value)

proc `%%%`*(value: int | int8 | int16 | int32 | int64): SurrealValue =
    ## Converts an integer to a SurrealValue
    return toSurrealInt(value)

proc toUInt8*(value: SurrealValue): uint8 =
    ## Converts a SurrealValue to an uint8.
    if value.kind != SurrealInteger:
        raise newException(ValueError, "Cannot convert a non-integer value to an uint8")
    if value.intIsNegative:
        raise newException(ValueError, "Cannot convert a negative integer value to an uint8")
    if value.intVal > uint8.high:
        raise newException(ValueError, "Cannot convert an integer value greater than 255 to an uint8")
    return value.intVal.uint8

proc toUInt16*(value: SurrealValue): uint16 =
    ## Converts a SurrealValue to an uint16.
    if value.kind != SurrealInteger:
        raise newException(ValueError, "Cannot convert a non-integer value to an uint16")
    if value.intIsNegative:
        raise newException(ValueError, "Cannot convert a negative integer value to an uint16")
    if value.intVal > uint16.high:
        raise newException(ValueError, "Cannot convert an integer value greater than 65535 to an uint16")
    return value.intVal.uint16

proc toUInt32*(value: SurrealValue): uint32 =
    ## Converts a SurrealValue to an uint32.
    if value.kind != SurrealInteger:
        raise newException(ValueError, "Cannot convert a non-integer value to an uint32")
    if value.intIsNegative:
        raise newException(ValueError, "Cannot convert a negative integer value to an uint32")
    if value.intVal > uint32.high:
        raise newException(ValueError, "Cannot convert an integer value greater than 4294967295 to an uint32")
    return value.intVal.uint32

proc toUInt64*(value: SurrealValue): uint64 =
    ## Converts a SurrealValue to an uint64.
    if value.kind != SurrealInteger:
        raise newException(ValueError, "Cannot convert a non-integer value to an uint64")
    if value.intIsNegative:
        raise newException(ValueError, "Cannot convert a negative integer value to an uint64")
    return value.intVal

proc toInt8*(value: SurrealValue): int8 =
    ## Converts a SurrealValue to an int8.
    if value.kind != SurrealInteger:
        raise newException(ValueError, "Cannot convert a non-integer value to an int8")

    const maxInt8: uint64 = int8.high.uint64
    const minInt8Positive: uint64 = (-(int8.low.int16)).uint64
    if value.intVal > (if value.intIsNegative: minInt8Positive else: maxInt8):
        raise newException(ValueError, "The stored value does not fit in an int8")

    return (value.intVal.int16 * (if value.intIsNegative: -1 else: 1)).int8

proc toInt16*(value: SurrealValue): int16 =
    ## Converts a SurrealValue to an int16.
    if value.kind != SurrealInteger:
        raise newException(ValueError, "Cannot convert a non-integer value to an int16")

    const maxInt16: uint64 = int16.high.uint64
    const minInt16Positive: uint64 = (-(int16.low.int32)).uint64
    if value.intVal > (if value.intIsNegative: minInt16Positive else: maxInt16):
        raise newException(ValueError, "The stored value does not fit in an int16")

    return (value.intVal.int32 * (if value.intIsNegative: -1 else: 1)).int16

proc toInt32*(value: SurrealValue): int32 =
    ## Converts a SurrealValue to an int32.
    if value.kind != SurrealInteger:
        raise newException(ValueError, "Cannot convert a non-integer value to an int32")

    const maxInt32: uint64 = int32.high.uint64
    const minInt32Positive: uint64 = (-(int32.low.int64)).uint64
    if value.intVal > (if value.intIsNegative: minInt32Positive else: maxInt32):
        raise newException(ValueError, "The stored value does not fit in an int32")

    return (value.intVal.int64 * (if value.intIsNegative: -1 else: 1)).int32

proc toInt64*(value: SurrealValue): int64 =
    ## Converts a SurrealValue to an int64.
    if value.kind != SurrealInteger:
        raise newException(ValueError, "Cannot convert a non-integer value to an int64")

    const maxInt64: uint64 = int64.high.uint64
    const minInt64Positive: uint64 = (int64.high - 1).uint64
    if value.intVal > (if value.intIsNegative: minInt64Positive else: maxInt64):
        raise newException(ValueError, "The stored value does not fit in an int64")

    return (value.intVal.int64 * (if value.intIsNegative: -1 else: 1))