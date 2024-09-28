proc toSurrealDatetime*(value: DateTime): SurrealValue =
    ## Converts a DateTime to a SurrealDatetime
    return SurrealValue(kind: SurrealDatetime, datetimeVal: value)

proc `%%%`*(value: DateTime): SurrealValue =
    ## Converts a DateTime to a SurrealDatetime
    return toSurrealDatetime(value)

proc getDateTime*(value: SurrealValue): DateTime =
    ## Extracts the DateTime value from the SurrealDatetime.
    case value.kind
    of SurrealDatetime:
        return value.datetimeVal
    else:
        raise newException(ValueError, "Cannot extract the DateTime value from a $1 value" % $value.kind)