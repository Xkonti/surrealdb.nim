import std/[sequtils, unittest]
import surreal/private/types/[duration, surrealValue]

suite "SurrealValue:Duration":

    test "Can extract seconds and nanoseconds":
        let duration = newSurrealDuration(123456789'u32, 123456789'u32)
        check(duration.seconds == 123456789'u32)
        check(duration.nanoseconds == 123456789'u32)

        let duration2 = newSurrealDuration()
        check(duration2.seconds == 0'u32)
        check(duration2.nanoseconds == 0'u32)

    test "Can add weeks":
        var duration1 = newSurrealDuration(0'u32, 0'u32)
        duration1.addWeeks(1)
        check(duration1.seconds.int == 7 * 24 * 60 * 60)
        check(duration1.nanoseconds == 0'u32)
        duration1.addWeeks(5)
        check(duration1.seconds.int == 6 * 7 * 24 * 60 * 60)
        check(duration1.nanoseconds == 0'u32)

        let duration2 = newSurrealDuration(0'u32, 0'u32)
        let duration3 = duration2.addWeeks(1)
        check(duration3.seconds.int == 7 * 24 * 60 * 60)
        check(duration3.nanoseconds == 0'u32)
        let duration4 = duration3.addWeeks(5)
        check(duration4.seconds.int == 6 * 7 * 24 * 60 * 60)
        check(duration4.nanoseconds == 0'u32)
        
    test "Can add days":
        var duration1 = newSurrealDuration(0'u32, 0'u32)
        duration1.addDays(1)
        check(duration1.seconds.int == 1 * 24 * 60 * 60)
        check(duration1.nanoseconds == 0'u32)
        duration1.addDays(12)
        check(duration1.seconds.int == 13 * 24 * 60 * 60)
        check(duration1.nanoseconds == 0'u32)

        let duration2 = newSurrealDuration(0'u32, 0'u32)
        let duration3 = duration2.addDays(1)
        check(duration3.seconds.int == 1 * 24 * 60 * 60)
        check(duration3.nanoseconds == 0'u32)
        let duration4 = duration3.addDays(12)
        check(duration4.seconds.int == 13 * 24 * 60 * 60)
        check(duration4.nanoseconds == 0'u32)
        
    test "Can add hours":
        var duration1 = newSurrealDuration(0'u32, 0'u32)
        duration1.addHours(1)
        check(duration1.seconds.int == 1 * 60 * 60)
        check(duration1.nanoseconds == 0'u32)
        duration1.addHours(3)
        check(duration1.seconds.int == 4 * 60 * 60)
        check(duration1.nanoseconds == 0'u32)

        let duration2 = newSurrealDuration(0'u32, 0'u32)
        let duration3 = duration2.addHours(1)
        check(duration3.seconds.int == 1 * 60 * 60)
        check(duration3.nanoseconds == 0'u32)
        let duration4 = duration3.addHours(3)
        check(duration4.seconds.int == 4 * 60 * 60)
        check(duration4.nanoseconds == 0'u32)
        
    test "Can add minutes":
        var duration1 = newSurrealDuration(0'u32, 0'u32)
        duration1.addMinutes(1)
        check(duration1.seconds.int == 1 * 60)
        check(duration1.nanoseconds == 0'u32)
        duration1.addMinutes(78)
        check(duration1.seconds.int == 79 * 60)
        check(duration1.nanoseconds == 0'u32)

        let duration2 = newSurrealDuration(0'u32, 0'u32)
        let duration3 = duration2.addMinutes(1)
        check(duration3.seconds.int == 1 * 60)
        check(duration3.nanoseconds == 0'u32)
        let duration4 = duration3.addMinutes(78)
        check(duration4.seconds.int == 79 * 60)
        check(duration4.nanoseconds == 0'u32)
        
    test "Can add seconds":
        var duration1 = newSurrealDuration(0'u32, 0'u32)
        duration1.addSeconds(1)
        check(duration1.seconds.int == 1)
        check(duration1.nanoseconds == 0'u32)
        duration1.addSeconds(56)
        check(duration1.seconds.int == 57)
        check(duration1.nanoseconds == 0'u32)

        let duration2 = newSurrealDuration(0'u32, 0'u32)
        let duration3 = duration2.addSeconds(1)
        check(duration3.seconds.int == 1)
        check(duration3.nanoseconds == 0'u32)
        let duration4 = duration3.addSeconds(56)
        check(duration4.seconds.int == 57)
        check(duration4.nanoseconds == 0'u32)
        
    test "Can add milliseconds":
        var duration1 = newSurrealDuration(0'u32, 0'u32)
        duration1.addMilliseconds(1)
        check(duration1.seconds == 0'u32)
        check(duration1.nanoseconds == 1_000_000'u32)
        duration1.addMilliseconds(1_200)
        check(duration1.seconds == 1'u32)
        check(duration1.nanoseconds == 201_000_000'u32)

        let duration2 = newSurrealDuration(0'u32, 0'u32)
        let duration3 = duration2.addMilliseconds(1)
        check(duration3.seconds == 0'u32) 
        check(duration3.nanoseconds == 1_000_000'u32)
        let duration4 = duration3.addMilliseconds(1_200)
        check(duration4.seconds == 1'u32) 
        check(duration4.nanoseconds == 201_000_000'u32)
        
    test "Can add microseconds":
        var duration1 = newSurrealDuration(0'u32, 0'u32)
        duration1.addMicroseconds(1)
        check(duration1.seconds == 0'u32)
        check(duration1.nanoseconds == 1_000'u32)
        duration1.addMicroseconds(5_400_000)
        check(duration1.seconds == 5'u32)
        check(duration1.nanoseconds == 400_001_000'u32)

        let duration2 = newSurrealDuration(0'u32, 0'u32)
        let duration3 = duration2.addMicroseconds(1)
        check(duration3.seconds == 0'u32) 
        check(duration3.nanoseconds == 1_000'u32)
        let duration4 = duration3.addMicroseconds(5_400_000)
        check(duration4.seconds == 5'u32) 
        check(duration4.nanoseconds == 400_001_000'u32)
        
    test "Can add nanoseconds":
        var duration1 = newSurrealDuration(0'u32, 0'u32)
        duration1.addNanoseconds(1)
        check(duration1.seconds == 0'u32)
        check(duration1.nanoseconds == 1'u32)
        duration1.addNanoseconds(78_483_992_003)
        check(duration1.seconds == 78'u32)
        check(duration1.nanoseconds == 483_992_004'u32)

        let duration2 = newSurrealDuration(0'u32, 0'u32)
        let duration3 = duration2.addNanoseconds(1)
        check(duration3.seconds == 0'u32) 
        check(duration3.nanoseconds == 1'u32)
        let duration4 = duration3.addNanoseconds(78_483_992_003)
        check(duration4.seconds == 78'u32) 
        check(duration4.nanoseconds == 483_992_004'u32)
        

    proc testDurationPairs(stringValues: seq[string], secValues: seq[int], nsValues: seq[int]) =
        for i in 0..<stringValues.len:
            let stringValue = stringValues[i]
            let secValue = secValues[i].uint32
            let nsValue = nsValues[i].uint32
            let surrealValue1 = stringValue.toSurrealValueDuration()
            let surrealValue2 = %%% stringValue.parseDuration
            check(surrealValue1.kind == SurrealDuration)
            check(surrealValue2.kind == SurrealDuration)
            check(surrealValue1 == surrealValue2)
            check(surrealValue1.getDuration.seconds == secValue)
            check(surrealValue2.getDuration.seconds == secValue)
            check(surrealValue1.getDuration.nanoseconds == nsValue)
            check(surrealValue2.getDuration.nanoseconds == nsValue)

    test "can be created from weeks-only string":
        const stringValues = @[
            "1w", "3w", "10w", "50w", "3000w"
        ]
        const secValues = @[
            1 * 7 * 24 * 60 * 60,
            3 * 7 * 24 * 60 * 60,
            10 * 7 * 24 * 60 * 60,
            50 * 7 * 24 * 60 * 60,
            3000 * 7 * 24 * 60 * 60
        ]
        const nsValues = @[0, 0, 0, 0, 0]
        testDurationPairs(stringValues, secValues, nsValues)

    test "can be created from days-only string":
        const stringValues = @[
            "1d", "5d", "30d", "200d"
        ]
        const secValues = @[
            1 * 24 * 60 * 60,
            5 * 24 * 60 * 60,
            30 * 24 * 60 * 60,
            200 * 24 * 60 * 60
        ]
        const nsValues = @[0, 0, 0, 0]
        testDurationPairs(stringValues, secValues, nsValues)

    test "can be created from hours-only string":
        const stringValues = @[
            "1h", "12h", "100h", "30000h"
        ]
        const secValues = @[
            1 * 60 * 60,
            12 * 60 * 60,
            100 * 60 * 60,
            30000 * 60 * 60
        ]
        const nsValues = @[0, 0, 0, 0]
        testDurationPairs(stringValues, secValues, nsValues)

    test "can be created from minutes-only string":
        const stringValues = @[
            "1m", "25m", "60m", "301m"
        ]
        const secValues = @[
            1 * 60,
            25 * 60,
            60 * 60,
            301 * 60
        ]
        const nsValues = @[0, 0, 0, 0, 0]
        testDurationPairs(stringValues, secValues, nsValues)

    test "can be created from seconds-only string":
        const stringValues = @[
            "1s", "60s", "300s", "9512s"
        ]
        const secValues = @[
            1, 60, 300, 9512
        ]
        const nsValues = @[0, 0, 0, 0]
        testDurationPairs(stringValues, secValues, nsValues)

    test "can be created from millisecond-only string":
        const stringValues = @[
            "1ms", "30ms", "900ms", "31205ms"
        ]
        const secValues = @[0, 0, 0, 31]
        const nsValues = @[1_000_000, 30_000_000, 900_000_000, 205_000_000]
        testDurationPairs(stringValues, secValues, nsValues)

    test "can be created from microseconds-only string":
        const stringValues = @[
            "1us", "300us", "125090us", "4291092us"
        ]
        const secValues = @[0, 0, 0, 4]
        const nsValues = @[1_000, 300_000, 125_090_000, 291_092_000]
        testDurationPairs(stringValues, secValues, nsValues)

    test "can be created from microseconds-only string":
        const stringValues = @[
            "1µs", "5092µs", "120999µs", "90111222µs"
        ]
        const secValues = @[0, 0, 0, 90]
        const nsValues = @[1_000, 5_092_000, 120_999_000, 111_222_000]
        testDurationPairs(stringValues, secValues, nsValues)

    test "can be created from microseconds-only string":
        const stringValues = @[
            "1μs", "59202μs", "999999μs", "1000000μs"
        ]
        const secValues = @[0, 0, 0, 1]
        const nsValues = @[1_000, 59_202_000, 999_999_000, 0]
        testDurationPairs(stringValues, secValues, nsValues)

    test "can be created from nanoseconds-only string":
        const stringValues = @[
            "1ns", "420000ns", "444222111ns", "5559992220ns"
        ]
        const secValues = @[0, 0, 0, 5]
        const nsValues = @[1, 420000, 444222111, 559992220]
        testDurationPairs(stringValues, secValues, nsValues)

    test "can be created from ordered string":
        const stringValues = @[
            "1w30m6000ms", "30h15m10s", "4w5s2555000222ns", "1w2d3h4m5s6ms7us8ns"
        ]
        const secValues = @[606606, 108910, 2419207, 788645]
        const nsValues = @[0, 0, 555000222, 6_007_008]
        testDurationPairs(stringValues, secValues, nsValues)

    test "can be created from mixed string":
        const stringValues = @[
            "30m6000ms1w", "15m10s30h", "4w2555000222ns5s", "5s6ms2d3h7us1w4m8ns"
        ]
        const secValues = @[606_606, 108_910, 2_419_207, 788_645]
        const nsValues = @[0, 0, 555_000_222, 6_007_008]
        testDurationPairs(stringValues, secValues, nsValues)

    test "can be created string with repeated parts":
        const stringValues = @[
            "1d1d5d", "1s30ms3s30ms", "3ms3m5ms1ms4s", "0s0s0s0s0s30s0s0s1000ms"
        ]
        const secValues = @[604_800, 4, 184, 31]
        const nsValues = @[0, 60_000_000, 9_000_000, 0]
        testDurationPairs(stringValues, secValues, nsValues)

    test "can compare durations":
        let v1 = "30d5h30m25s30us".parseDuration
        let v2 = "5h30m30d30us25s".parseDuration
        check(v1 == v2)
        let s1 = v1.toSurrealValueDuration
        let s2 = %%% v2
        check(s1 == s2)
