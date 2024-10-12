proc toSurrealFloat*(value: float64 | float32): SurrealValue =
    ## Converts a float to a SurrealFloat
    return SurrealValue(kind: SurrealFloat, floatVal: value.float64)

proc `%%%`*(value: float64 | float32): SurrealValue =
    ## Converts a float to a SurrealFloat
    return toSurrealFloat(value)