proc toSurrealValueDuration*(value: SurrealDuration): SurrealValue =
    ## Converts a Duration to a SurrealDuration
    return SurrealValue(kind: SurrealDuration, durationVal: value)

proc toSurrealValueDuration*(value: string): SurrealValue =
    ## Parses a string into a SurrealDuration
    return value.parseDuration.toSurrealValueDuration()

proc `%%%`*(value: SurrealDuration): SurrealValue =
    ## Converts a Duration to a SurrealDuration
    return toSurrealValueDuration(value)

proc getDuration*(value: SurrealValue): SurrealDuration =
    ## Extracts the Duration value from the SurrealDuration.
    case value.kind
    of SurrealDuration:
        return value.durationVal
    else:
        raise newException(ValueError, "Cannot extract the Duration value from a $1 value" % $value.kind)
