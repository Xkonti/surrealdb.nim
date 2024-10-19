proc toSurrealDatetime*(value: DateTime): SurrealValue =
    ## Converts a DateTime to a SurrealDatetime
    return SurrealValue(kind: SurrealDatetime, datetimeVal: value.toTime)

proc toSurrealDatetime*(value: Time): SurrealValue =
    ## Converts a DateTime to a SurrealDatetime
    return SurrealValue(kind: SurrealDatetime, datetimeVal: value)

proc newSurrealDatetime*(seconds: uint64, nanoseconds: NanosecondRange = 0): SurrealValue =
    ## Converts seconds (since epoch) and nanoseconds to a SurrealDatetime
    return SurrealValue(kind: SurrealDatetime, datetimeVal: initTime(seconds.int64, nanoseconds))

proc toSurrealDatetime*(isoDate: string): SurrealValue =
    ## Parses an ISO8601 date string and converts it to a SurrealDatetime
    ## Current parsing implementation is very basic and only supports the following formats:
    ## - 2024-04-12T06:04:02Z
    ## - 2024-04-12T06:04:02.021Z
    ## - 2024-04-12T06:04:02+03:00
    ## - 2024-04-12T06:04:02+03
    ## - 2024-04-12T06:04:02+3
    ## - 2024-04-12T06:04:02.021+03:00
    ## - 2024-04-12T06:04:02.021+03
    ## - 2024-04-12T06:04:02.021+3

    #  Check minimum length of acceptable datetime string: 2000-01-01T00:00:00Z
    if isoDate.len < 20:
        raise newException(ValueError, "Invalid datetime string: " & isoDate)
    # Check if within maximum acceptable datetime length: 2000-01-01T00:00:00.000+00:00
    if isoDate.len > 29:
        raise newException(ValueError, "Invalid datetime string: " & isoDate)

    # No matter the format variant, we can extract the initial yyyy-MM-ddTHH:mm:ss part
    var staticPart = isoDate.substr(0, 18)

    # Extract data from the static part
    let staticParts = staticPart.match(re"(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})")
    let year = staticParts[1].parseInt
    let month = staticParts[2].parseInt
    let day = staticParts[3].parseInt
    let hour = staticParts[4].parseInt
    let minute = staticParts[5].parseInt
    let second = staticParts[6].parseInt
    
    # Take the rest of the string
    let variablePart = isoDate.substr(19)

    # Single character means it's just the time zone
    if variablePart.len == 1:
        if variablePart == "Z":
          return dateTime(year, month.Month, day, hour, minute, second, zone = utc()).toSurrealDatetime()
        # No other single-character value is supported
        raise newException(ValueError, "Invalid datetime string: " & isoDate)

    # Parse additional parts (ms & timezone)
    #   ALL              MS          TZ            HR          MIN
    # ".021+03:00", ".021", "021", "+03:00", "+", "03", ":00", "00"]
    let variableParts = variablePart.match(re"(\.(\d+))?(Z|([+-])(\d{2})(:(\d{2}))?)")

    # Milliseconds
    var ms = 0
    if variableParts[2] != "":
        ms = variableParts[2].parseInt

    var value = dateTime(
        year = year, month = month.Month, monthday = day,
        hour = hour, minute = minute,
        second = second, nanosecond = ms * 1_000_000,
        zone = utc()
    )

    # Timezone
    if variableParts[3] == "Z":
        return value.toSurrealDatetime()

    # Timezone offsets
    let isPositive = case variableParts[4]:
        of "+": true
        of "-": false
        else: raise newException(ValueError, "Invalid datetime string: " & isoDate)
    let hoursOffset = variableParts[5].parseInt
    let minutesOffset = if variableParts[7] != "": variableParts[7].parseInt else: 0
    let offsetDuration = initDuration(hours = hoursOffset, minutes = minutesOffset)
    if isPositive:
        value -= offsetDuration
    else:
        value += offsetDuration
    return value.toSurrealDatetime()

proc `%%%`*(value: DateTime | Time): SurrealValue =
    ## Converts a DateTime to a SurrealDatetime
    return toSurrealDatetime(value)

proc getDateTime*(value: SurrealValue): DateTime =
    ## Extracts the DateTime value from the SurrealDatetime.
    case value.kind
    of SurrealDatetime:
        return value.datetimeVal.utc()
    else:
        raise newException(ValueError, "Cannot extract the DateTime value from a $1 value" % $value.kind)
        
proc getTime*(value: SurrealValue): Time =
    ## Extracts the DateTime value from the SurrealDatetime.
    case value.kind
    of SurrealDatetime:
        return value.datetimeVal
    else:
        raise newException(ValueError, "Cannot extract the Time value from a $1 value" % $value.kind)
        
