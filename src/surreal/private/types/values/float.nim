proc toSurrealFloat*(value: float32): SurrealValue =
    ## Converts a float32 to a SurrealFloat
    return SurrealValue(kind: SurrealFloat, floatKind: Float32, float32Val: value)

proc toSurrealFloat*(value: float64): SurrealValue =
    ## Converts a float64 to a SurrealFloat
    return SurrealValue(kind: SurrealFloat, floatKind: Float64, float64Val: value)

proc `%%%`*(value: float64 | float32): SurrealValue =
    ## Converts a float to a SurrealFloat
    return toSurrealFloat(value)

proc getFloat32*(value: SurrealValue): float32 =
    ## Extracts the float32 value from the SurrealFloat Float32 variant.
    if value.kind != SurrealFloat:
        raise newException(ValueError, "Cannot extract the float32 value from a $1 value" % $value.kind)
    if value.floatKind != Float32:
        raise newException(ValueError, "Cannot extract the float32 value from a $1 value" % $value.floatKind)
    return value.float32Val

proc getFloat64*(value: SurrealValue): float64 =
    ## Extracts the float64 value from the SurrealFloat Float64 variant.
    if value.kind != SurrealFloat:
        raise newException(ValueError, "Cannot extract the float64 value from a $1 value" % $value.kind)
    if value.floatKind != Float64:
        raise newException(ValueError, "Cannot extract the float64 value from a $1 value" % $value.floatKind)
    return value.float64Val
