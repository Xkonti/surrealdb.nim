import std/[sequtils, unittest]
import surreal/private/types/[surrealValue]

const upToUInt8: seq[uint8] = (0'u8..255'u8).toSeq
const upToUint16: seq[uint16] = (0'u16..255'u16).toSeq &
    @[400'u16, 1000, 9000, 30000, uint16.high]
const upToUint32: seq[uint32] = (0'u32..255'u32).toSeq &
    @[400'u32, 1000, 9000, 30000, uint16.high.uint32] &
    @[60_000'u32, 1_000_000, 12_900_000, 300_000_000, uint32.high]
const upToUint64: seq[uint64] = (0'u64..255'u64).toSeq &
    @[400'u64, 1000, 9000, 30000, uint16.high.uint64] &
    @[60_000'u64, 1_000_000, 12_900_000, 300_000_000, uint32.high.uint64] &
    @[600_000_000_000'u64, 300_000_000_000_000'u64, uint64.high]

suite "SurrealValue:Integer":

    test "Should handle positive uint8":
        for value in upToUInt8:
            let surrealValue = value.toSurrealInt()
            check(surrealValue.kind == SurrealInteger)
            check(surrealValue.isPositive)
            check(not surrealValue.isNegative)
            check(surrealValue.toUInt8 == value)
            check(surrealValue.toUInt16 == value.uint16)
            check(surrealValue.toUInt32 == value.uint32)
            check(surrealValue.toUInt64 == value.uint64)
            check(surrealValue.toInt16 == value.int16)
            check(surrealValue.toInt32 == value.int32)
            check(surrealValue.toInt64 == value.int64)

            let surrealValue2 = %%%value
            check(surrealValue2 == surrealValue)


    test "Should handle positive uint16":
        for value in upToUint16:
            let surrealValue = value.toSurrealInt()
            check(surrealValue.kind == SurrealInteger)
            check(surrealValue.isPositive)
            check(not surrealValue.isNegative)
            check(surrealValue.toUInt16 == value)
            check(surrealValue.toUInt32 == value.uint32)
            check(surrealValue.toUInt64 == value.uint64)
            check(surrealValue.toInt32 == value.int32)
            check(surrealValue.toInt64 == value.int64)

            let surrealValue2 = %%%value
            check(surrealValue2 == surrealValue)

    test "Should handle positive uint32":
        for value in upToUint32:
            let surrealValue = value.toSurrealInt()
            check(surrealValue.kind == SurrealInteger)
            check(surrealValue.isPositive)
            check(not surrealValue.isNegative)
            check(surrealValue.toUInt32 == value)
            check(surrealValue.toUInt64 == value.uint64)
            check(surrealValue.toInt64 == value.int64)

            let surrealValue2 = %%%value
            check(surrealValue2 == surrealValue)

    test "Should handle positive uint64":
        for value in upToUint64:
            let surrealValue = value.toSurrealInt()
            check(surrealValue.kind == SurrealInteger)
            check(surrealValue.isPositive)
            check(not surrealValue.isNegative)
            check(surrealValue.toUInt64 == value)

            let surrealValue2 = %%%value
            check(surrealValue2 == surrealValue)


    test "Should handle negative uint8":
        for value in @[1'u8, 2, 5, 10, 24, 50, 100, 126, 127]:
            let surrealValue = value.uint64.toSurrealNegativeInt()
            check(surrealValue.kind == SurrealInteger)
            check(not surrealValue.isPositive)
            check(surrealValue.isNegative)
            check(surrealValue.toInt8 == -value.int8)
            check(surrealValue.toInt16 == -value.int16)
            check(surrealValue.toInt32 == -value.int32)
            check(surrealValue.toInt64 == -value.int64)

    test "Should handle negative uint16":
        const values: seq[uint16] = @[
            1'u16, 2, 5, 10, 24, 50, 100, 126, 127,
            128, 255, 256, 9000, int16.high.uint16
        ]
        for value in values:
            let surrealValue = value.uint64.toSurrealNegativeInt()
            check(surrealValue.kind == SurrealInteger)
            check(not surrealValue.isPositive)
            check(surrealValue.isNegative)
            check(surrealValue.toInt16 == -value.int16)
            check(surrealValue.toInt32 == -value.int32)
            check(surrealValue.toInt64 == -value.int64)

    test "Should handle negative uint32":
        const values: seq[uint32] = @[
            1'u32, 2, 5, 10, 24, 50, 100, 126, 127,
            128, 255, 256, 9000, int16.high.uint32,
            1_000_000, 321_456_987, int32.high.uint32
        ]
        for value in values:
            let surrealValue = value.uint64.toSurrealNegativeInt()
            check(surrealValue.kind == SurrealInteger)
            check(not surrealValue.isPositive)
            check(surrealValue.isNegative)
            check(surrealValue.toInt32 == -value.int32)
            check(surrealValue.toInt64 == -value.int64)

    test "Should handle negative uint64":
        const values: seq[uint64] = @[
            1'u64, 2, 5, 10, 24, 50, 100, 126, 127,
            128, 255, 256, 9000, int16.high.uint64,
            1_000_000, 321_456_987, int32.high.uint64,
            480_115_974_452_884'u64, int64.high.uint64
        ]
        for value in values:
            let surrealValue = value.uint64.toSurrealNegativeInt()
            check(surrealValue.kind == SurrealInteger)
            check(not surrealValue.isPositive)
            check(surrealValue.isNegative)
            check(surrealValue.toInt64 == -value.int64)

    test "Should handle any int8":
        const values: seq[int8] = @[
            0'i8, -1, 1, -3, 5, 24, -31, 127, -128
        ]
        for value in values:
            let surrealValue = value.toSurrealInt()
            check(surrealValue.kind == SurrealInteger)
            if value >= 0:
                check(surrealValue.isPositive)
                check(not surrealValue.isNegative)
            else:
                check(not surrealValue.isPositive)
                check(surrealValue.isNegative)

            check(surrealValue.toInt8 == value.int8)
            check(surrealValue.toInt16 == value.int16)
            check(surrealValue.toInt32 == value.int32)
            check(surrealValue.toInt64 == value.int64)

    test "Should handle any int16":
        const values: seq[int16] = @[
            0'i16, -1, 1, -3, 5, 24, -31, 127, -128,
            128, -129, 255, 256, -255, -256, int16.high, int16.low
        ]
        for value in values:
            let surrealValue = value.toSurrealInt()
            check(surrealValue.kind == SurrealInteger)
            if value >= 0:
                check(surrealValue.isPositive)
                check(not surrealValue.isNegative)
            else:
                check(not surrealValue.isPositive)
                check(surrealValue.isNegative)

            check(surrealValue.toInt16 == value.int16)
            check(surrealValue.toInt32 == value.int32)
            check(surrealValue.toInt64 == value.int64)

    test "Should handle any int32":
        const values: seq[int32] = @[
            0'i32, -1, 1, -3, 5, 24, -31, 127, -128,
            128, -129, 255, 256, -255, -256, int16.high, int16.low,
            501_978, -68_099_124, int32.high, int32.low
        ]
        for value in values:
            let surrealValue = value.toSurrealInt()
            check(surrealValue.kind == SurrealInteger)
            if value >= 0:
                check(surrealValue.isPositive)
                check(not surrealValue.isNegative)
            else:
                check(not surrealValue.isPositive)
                check(surrealValue.isNegative)

            check(surrealValue.toInt32 == value.int32)
            check(surrealValue.toInt64 == value.int64)

    test "Should handle any int64":
        const values: seq[int64] = @[
            0'i64, -1, 1, -3, 5, 24, -31, 127, -128,
            128, -129, 255, 256, -255, -256, int16.high, int16.low,
            501_978, -68_099_124, int32.high, int32.low,
            684_448_974_771_112_354'i64, -5_971_678_102_111_880_051'i64, int64.high, int64.low
        ]
        for value in values:
            let surrealValue = value.toSurrealInt()
            check(surrealValue.kind == SurrealInteger)
            if value >= 0:
                check(surrealValue.isPositive)
                check(not surrealValue.isNegative)
            else:
                check(not surrealValue.isPositive)
                check(surrealValue.isNegative)

            check(surrealValue.toInt64 == value.int64)

            let surrealValue2 = %%%value
            check(surrealValue2 == surrealValue)