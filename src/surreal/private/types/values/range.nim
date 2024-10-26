
proc newSurrealRange*(startValue: SurrealValue, endValue: SurrealValue, isStartInclusive: bool, isEndInclusive: bool): SurrealValue =
    ## Create a new SurrealRange with both start and end values
    case isStartInclusive:
    of true:
        case isEndInclusive:
        of true:
            return SurrealValue(kind: SurrealRange, rangeStartBound: Inclusive, rangeStartVal: startValue, rangeEndBound: Inclusive, rangeEndVal: endValue)
        of false:
            return SurrealValue(kind: SurrealRange, rangeStartBound: Inclusive, rangeStartVal: startValue, rangeEndBound: Exclusive, rangeEndVal: endValue)
    of false:
        case isEndInclusive:
        of true:
            return SurrealValue(kind: SurrealRange, rangeStartBound: Exclusive, rangeStartVal: startValue, rangeEndBound: Inclusive, rangeEndVal: endValue)
        of false:
            return SurrealValue(kind: SurrealRange, rangeStartBound: Exclusive, rangeStartVal: startValue, rangeEndBound: Exclusive, rangeEndVal: endValue)

proc newSurrealStartOnlyRange*(startValue: SurrealValue, isStartInclusive: bool): SurrealValue =
    ## Create a new SurrealRange with only start value - the end value is unbounded
    case isStartInclusive:
    of true:
        return SurrealValue(kind: SurrealRange, rangeStartBound: Inclusive, rangeStartVal: startValue, rangeEndBound: Unbounded)
    of false:
        return SurrealValue(kind: SurrealRange, rangeStartBound: Exclusive, rangeStartVal: startValue, rangeEndBound: Unbounded)

proc newSurrealEndOnlyRange*(endValue: SurrealValue, isEndInclusive: bool): SurrealValue =
    ## Create a new SurrealRange with only end value - the start value is unbounded
    case isEndInclusive:
    of true:
        return SurrealValue(kind: SurrealRange, rangeStartBound: Unbounded, rangeEndBound: Inclusive, rangeEndVal: endValue)
    of false:
        return SurrealValue(kind: SurrealRange, rangeStartBound: Unbounded, rangeEndBound: Exclusive, rangeEndVal: endValue)

proc getRangeStart*(value: SurrealValue): SurrealValue =
    ## Extracts the start value from the SurrealRange
    if value.kind != SurrealRange:
        raise newException(ValueError, "Cannot extract the start value from a $1 value" % $value.kind)
    return if value.rangeStartBound == Unbounded: surrealNone else: value.rangeStartVal

proc getRangeEnd*(value: SurrealValue): SurrealValue =
    ## Extracts the end value from the SurrealRange.
    if value.kind != SurrealRange:
        raise newException(ValueError, "Cannot extract the end value from a $1 value" % $value.kind)
    return if value.rangeEndBound == Unbounded: surrealNone else: value.rangeEndVal

proc getRangeValues*(value: SurrealValue): (SurrealValue, SurrealValue) =
    ## Extracts the start and end values from the SurrealRange
    if value.kind != SurrealRange:
        raise newException(ValueError, "Cannot extract the start and end values from a $1 value" % $value.kind)
    let startValue = if value.rangeStartBound == Unbounded: surrealNone else: value.rangeStartVal
    let endValue = if value.rangeEndBound == Unbounded: surrealNone else: value.rangeEndVal
    return (startValue, endValue)

proc getStartBound*(value: SurrealValue): SurrealBoundKind =
    ## Extracts the start bound from the SurrealRange
    if value.kind != SurrealRange:
        raise newException(ValueError, "Cannot extract the start bound from a $1 value" % $value.kind)
    return value.rangeStartBound

proc getEndBound*(value: SurrealValue): SurrealBoundKind =
    ## Extracts the end bound from the SurrealRange
    if value.kind != SurrealRange:
        raise newException(ValueError, "Cannot extract the end bound from a $1 value" % $value.kind)
    return value.rangeEndBound
