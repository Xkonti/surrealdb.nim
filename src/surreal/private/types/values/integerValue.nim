# ==== From integers to SurrealValues ====

proc toSurrealInt*(value: uint | uint8 | uint16 | uint32 | uint64): SurrealValue =
    ## Converts an integer to a SurrealValue
    return SurrealValue(kind: SurrealInteger, intVal: value.uint64, intIsNegative: false)

proc toSurrealNegativeInt*(value: uint | uint8 | uint16 | uint32 | uint64): SurrealValue =
    ## Converts a positive integer to a negative SurrealValue
    # The stored value is made smaller by 1 to be able to fit it properly
    return SurrealValue(kind: SurrealInteger, intVal: value.uint64 - 1, intIsNegative: true)

proc toSurrealNegativeIntRaw*(value: uint64): SurrealValue =
    ## Converts an integer to a negative SurrealValue - this will not modify the value as it
    ## assumes the the value is already adjusted by 1 (to be compatible with the CBOR format)
    return SurrealValue(kind: SurrealInteger, intVal: value, intIsNegative: true)

proc toSurrealInt*(value: int | int8 | int16 | int32 | int64): SurrealValue =
    ## Converts an integer to a SurrealValue
    if value < 0:
        return SurrealValue(kind: SurrealInteger, intVal: (-(value.int64 + 1'i64)).uint64, intIsNegative: true)
    return SurrealValue(kind: SurrealInteger, intVal: value.uint64, intIsNegative: false)

proc `%%%`*(value: uint | uint8 | uint16 | uint32 | uint64): SurrealValue =
    ## Converts an integer to a SurrealValue
    return toSurrealInt(value)

proc `%%%`*(value: int | int8 | int16 | int32 | int64): SurrealValue =
    ## Converts an integer to a SurrealValue
    return toSurrealInt(value)


# ==== From SurrealValues to integers ====

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
    if value.intVal > maxInt8:
        raise newException(ValueError, "The stored value $1 does not fit in an int8" % $value.intVal)

    if value.intIsNegative:
        return ((value.intVal.int16 * -1) - 1).int8
    else:
        return value.intVal.int8

proc toInt16*(value: SurrealValue): int16 =
    ## Converts a SurrealValue to an int16.
    if value.kind != SurrealInteger:
        raise newException(ValueError, "Cannot convert a non-integer value to an int16")

    const maxInt16: uint64 = int16.high.uint64
    if value.intVal > maxInt16:
        raise newException(ValueError, "The stored value $1 does not fit in an int16" % $value.intVal)

    if value.intIsNegative:
        return ((value.intVal.int32 * -1) - 1).int16
    else:
        return value.intVal.int16

proc toInt32*(value: SurrealValue): int32 =
    ## Converts a SurrealValue to an int32.
    if value.kind != SurrealInteger:
        raise newException(ValueError, "Cannot convert a non-integer value to an int32")

    const maxInt32: uint64 = int32.high.uint64
    if value.intVal > maxInt32:
        raise newException(ValueError, "The stored value $1 does not fit in an int32" % $value.intVal)

    if value.intIsNegative:
        return ((value.intVal.int64 * -1) - 1).int32
    else:
        return value.intVal.int32

proc toInt64*(value: SurrealValue): int64 =
    ## Converts a SurrealValue to an int64.
    if value.kind != SurrealInteger:
        raise newException(ValueError, "Cannot convert a non-integer value to an int64")

    const maxInt64: uint64 = int64.high.uint64
    if value.intVal > maxInt64:
        raise newException(ValueError, "The stored value $1 does not fit in an int64" % $value.intVal)

    if value.intIsNegative:
        return ((value.intVal.int64 * -1) - 1).int64
    else:
        return value.intVal.int64

# TODO: Add support for larger integers - we need an equivalent of negative uint64


# ==== Sign checking ====

proc isPositive*(value: SurrealValue): bool =
    ## Checks if the SurrealValue is positive.
    case value.kind
    of SurrealInteger:
        return not value.intIsNegative
    # of SurrealFloat:
    #     return value.floatVal > 0
    else:
        raise newException(ValueError, "Cannot check the sign of a non-integer value")

proc isNegative*(value: SurrealValue): bool =
    ## Checks if the SurrealValue is negative.
    return not isPositive(value)