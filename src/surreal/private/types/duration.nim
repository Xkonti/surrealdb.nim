import std/[strutils]
import tinyre

type
    SurrealDuration* = object
        seconds: uint32
        nanoseconds: uint32

proc seconds*(duration: SurrealDuration): uint32 =
    ## Returns the number of seconds in the duration.
    return duration.seconds

proc nanoseconds*(duration: SurrealDuration): uint32 =
    ## Returns the number of nanoseconds in the duration.
    return duration.nanoseconds

const secondsInMinute: uint32 = 60
const secondsInHour: uint32 = 60 * secondsInMinute
const secondsInDay: uint32 = 24 * secondsInHour
const secondsInWeek: uint32 = 7 * secondsInDay

const nsInMicrosecond: uint32 = 1_000
const nsInMillisecond: uint32 = 1_000 * nsInMicroSecond
const nsInSecond: uint32 = 1_000 * nsInMillisecond

proc newSurrealDuration*(seconds: SomeInteger = 0, nanoseconds: SomeInteger = 0): SurrealDuration =
    assert seconds >= 0 and nanoseconds >= 0
    return SurrealDuration(seconds: seconds.uint32, nanoseconds: nanoseconds.uint32)

proc addWeeks*(duration: var SurrealDuration, weeks: SomeInteger) =
    duration.seconds += weeks.uint32 * secondsInWeek

proc addWeeks*(duration: SurrealDuration, weeks: SomeInteger): SurrealDuration =
    return SurrealDuration(
        seconds: duration.seconds + weeks.uint32 * secondsInWeek,
        nanoseconds: duration.nanoseconds
    )

proc addDays*(duration: var SurrealDuration, days: SomeInteger) =
    duration.seconds += days.uint32 * secondsInDay

proc addDays*(duration: SurrealDuration, days: SomeInteger): SurrealDuration =
    return SurrealDuration(
        seconds: duration.seconds + days.uint32 * secondsInDay,
        nanoseconds: duration.nanoseconds
    )

proc addHours*(duration: var SurrealDuration, hours: SomeInteger) =
    duration.seconds += hours.uint32 * secondsInHour

proc addHours*(duration: SurrealDuration, hours: SomeInteger): SurrealDuration =
    return SurrealDuration(
        seconds: duration.seconds + hours.uint32 * secondsInHour,
        nanoseconds: duration.nanoseconds
    )

proc addMinutes*(duration: var SurrealDuration, minutes: SomeInteger) =
    duration.seconds += minutes.uint32 * secondsInMinute

proc addMinutes*(duration: SurrealDuration, minutes: SomeInteger): SurrealDuration =
    return SurrealDuration(
        seconds: duration.seconds + minutes.uint32 * secondsInMinute,
        nanoseconds: duration.nanoseconds
    )

proc addSeconds*(duration: var SurrealDuration, seconds: SomeInteger) =
    duration.seconds += seconds.uint32

proc addSeconds*(duration: SurrealDuration, seconds: SomeInteger): SurrealDuration =
    return SurrealDuration(
        seconds: duration.seconds + seconds.uint32,
        nanoseconds: duration.nanoseconds
    )

proc addMilliseconds*(duration: var SurrealDuration, milliseconds: SomeInteger) =
    let secondsToAdd = milliseconds.uint32 div 1_000
    let nanosecondsToAdd = (milliseconds.uint32 mod 1_000) * nsInMillisecond
    duration.seconds += secondsToAdd
    duration.nanoseconds += nanosecondsToAdd
    if duration.nanoseconds.uint32 >= nsInSecond:
        duration.seconds += 1
        duration.nanoseconds -= nsInSecond

proc addMilliseconds*(duration: SurrealDuration, milliseconds: SomeInteger): SurrealDuration =
    let secondsToAdd = milliseconds.uint32 div 1_000
    let nanosecondsToAdd = (milliseconds.uint32 mod 1_000) * nsInMillisecond
    var seconds = duration.seconds + secondsToAdd
    var ns = duration.nanoseconds + nanosecondsToAdd
    if ns >= nsInSecond:
        seconds += 1
        ns -= nsInSecond
    return SurrealDuration(seconds: seconds, nanoseconds: ns)

proc addMicroseconds*(duration: var SurrealDuration, microseconds: SomeInteger) =
    let secondsToAdd = microseconds.uint32 div 1_000_000
    let nanosecondsToAdd = (microseconds.uint32 mod 1_000_000) * nsInMicrosecond
    duration.seconds += secondsToAdd
    duration.nanoseconds += nanosecondsToAdd
    if duration.nanoseconds.uint32 >= nsInSecond:
        duration.seconds += 1
        duration.nanoseconds -= nsInSecond

proc addMicroseconds*(duration: SurrealDuration, microseconds: SomeInteger): SurrealDuration =
    let secondsToAdd = microseconds.uint32 div 1_000_000
    let nanosecondsToAdd = (microseconds.uint32 mod 1_000_000) * nsInMicrosecond
    var seconds = duration.seconds + secondsToAdd
    var ns = duration.nanoseconds + nanosecondsToAdd
    if ns >= nsInSecond:
        seconds += 1
        ns -= nsInSecond
    return SurrealDuration(seconds: seconds, nanoseconds: ns)

proc addNanoseconds*(duration: var SurrealDuration, nanoseconds: SomeInteger) =
    let secondsToAdd = nanoseconds.uint64 div 1_000_000_000'u64
    let nanosecondsToAdd = nanoseconds.uint64 mod 1_000_000_000'u64
    duration.seconds += secondsToAdd.uint32
    duration.nanoseconds += nanosecondsToAdd.uint32
    if duration.nanoseconds.uint32 >= nsInSecond:
        duration.seconds += 1
        duration.nanoseconds -= nsInSecond

proc addNanoseconds*(duration: SurrealDuration, nanoseconds: SomeInteger): SurrealDuration =
    let secondsToAdd = nanoseconds.uint64 div 1_000_000_000'u64
    let nanosecondsToAdd = nanoseconds.uint64 mod 1_000_000_000'u64
    var seconds = duration.seconds + secondsToAdd.uint32
    var ns = duration.nanoseconds + nanosecondsToAdd.uint32
    if ns >= nsInSecond:
        seconds += 1
        ns -= nsInSecond
    return SurrealDuration(seconds: seconds, nanoseconds: ns)

proc parseDuration*(value: string): SurrealDuration =
    # Duration example: 12w3d4h5m12s2ms5us5ns
    # Somehow those microsecond units are different here
    # We'll replace them with `us` to avoid UTC issues
    let parts = value.match(reUG"(\d+)(ms|us|µs|μs|ns|w|d|h|m|s)")
    if parts.len == 0 or parts[0].len == 0:
        raise newException(ValueError, "Invalid duration format: " & value)
    var duration = newSurrealDuration()
    var index = 0
    while index < parts.len:
        let number = parts[index + 1].parseInt
        let unit = parts[index + 2]
        index += 3 # Results come in groups of 3 (30ms, 30, ms)
        case unit:
        of "w":
            duration.addWeeks(number)
        of "d":
            duration.addDays(number)
        of "h":
            duration.addHours(number)
        of "m":
            duration.addMinutes(number)
        of "s":
            duration.addSeconds(number)
        of "ms":
            duration.addMilliseconds(number)
        of "us", "µs", "μs": # The UTF-8 for the greek small letter MU: 0xCE, 0xBC
            duration.addMicroseconds(number)
        of "ns":
            duration.addNanoseconds(number)
        else:
            raise newException(ValueError, "Invalid duration format: " & value)
    return duration

proc `==`*(a, b: SurrealDuration): bool =
    return a.seconds == b.seconds and a.nanoseconds == b.nanoseconds

