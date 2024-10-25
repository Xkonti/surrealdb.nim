proc toSurrealRange*(start: SurrealValue, end: SurrealValue, isStartInclusive: bool, isEndInclusive: bool): SurrealValue =
    ## Converts a tuple of SurrealValues to a SurrealRange
    return SurrealValue(
        kind: SurrealRange, rangeStartVal: start, rangeEndVal: end,
        isRangeStartInclusive: isStartInclusive, isRangeEndInclusive: isEndInclusive
    )

proc getRangeStart*(value: SurrealValue): SurrealValue =
    ## Extracts the start value from the SurrealRange.
    case value.kind
    of SurrealRange:
        return value.rangeStartVal
    else:
        raise newException(ValueError, "Cannot extract the start value from a $1 value" % $value.kind)

proc getRangeEnd*(value: SurrealValue): SurrealValue =
    ## Extracts the end value from the SurrealRange.
    case value.kind
    of SurrealRange:
        return value.rangeEndVal
    else:
        raise newException(ValueError, "Cannot extract the end value from a $1 value" % value.kind)

proc getRangeValues*(value: SurrealValue): (SurrealValue, SurrealValue) =
    ## Extracts the start and end values from the SurrealRange.
    case value.kind
    of SurrealRange:
        return (value.rangeStartVal, value.rangeEndVal)
    else:
        raise newException(ValueError, "Cannot extract the start and end values from a $1 value" % value.kind)

proc isRangeStartInclusive*(value: SurrealValue): bool =
    ## Checks if the start value of the SurrealRange is inclusive.
    case value.kind
    of SurrealRange:
        return value.isRangeStartInclusive
    else:
        raise newException(ValueError, "Cannot check the start value of a $1 value" % value.kind)

proc isRangeEndInclusive*(value: SurrealValue): bool =
    ## Checks if the end value of the SurrealRange is inclusive.
    case value.kind
    of SurrealRange:
        return value.isRangeEndInclusive
    else:
        raise newException(ValueError, "Cannot check the end value of a $1 value" % value.kind)
