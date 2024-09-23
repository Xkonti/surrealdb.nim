import std/unittest
import surreal/private/cbor/[decoder, encoder, types]
import surreal/private/types/[surrealTypes, surrealValue]

suite "CBOR:Decoder:Integers":

    test "decode positive integers":
        const numbers: seq[uint64] = @[0, 6, 23, 24, 500, 69420, uint32.high, uint32.high + 1, uint64.high]
        for number in numbers:
            let data = encodeHead(PosInt, number)
            let decoded = decode(data)
            check(decoded.kind == SurrealInteger)
            check(decoded.intIsNegative == false)
            check(decoded.intVal == number)

    test "decode positive embedded integer":
        const number = 9'u64
        const data = encodeHead(PosInt, number)
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == false)
        check(decoded.intVal == number)
        check(decoded.toInt8 == number.int8)
        check(decoded.toInt16 == number.int16)
        check(decoded.toInt32 == number.int32)
        check(decoded.toInt64 == number.int64)
        check(decoded.toUInt8 == number.uint8)
        check(decoded.toUInt16 == number.uint16)
        check(decoded.toUInt32 == number.uint32)
        check(decoded.toUInt64 == number.uint64)

    test "decode positive uint8 integer":
        const number = 69'u64
        const data = encodeHead(PosInt, number)
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == false)
        check(decoded.intVal == number)
        check(decoded.toInt8 == number.int8)
        check(decoded.toInt16 == number.int16)
        check(decoded.toInt32 == number.int32)
        check(decoded.toInt64 == number.int64)
        check(decoded.toUInt8 == number.uint8)
        check(decoded.toUInt16 == number.uint16)
        check(decoded.toUInt32 == number.uint32)
        check(decoded.toUInt64 == number.uint64)

    test "decode positive uint64 integer":
        const number = 6_942_069_420_694_206_942'u64
        const data = encodeHead(PosInt, number)
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == false)
        check(decoded.intVal == number)
        check(decoded.toUInt64 == number)


    test "decode negative integers":
        const numbers: seq[uint64] = @[0, 6, 23, 24, 500, 69420, uint32.high, uint32.high + 1, int64.high.uint64]
        for number in numbers:
            let data = encodeHead(NegInt, number)
            let decoded = decode(data)
            check(decoded.kind == SurrealInteger)
            check(decoded.intIsNegative == true)
            check(decoded.intVal == number)
            check(decoded.toInt64 == -number.int64 - 1)


    test "decode negative integer #0":
        const data = encodeHead(NegInt, 0)
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == true)
        check(decoded.intVal == 0)
        const number = -1'i64
        check(decoded.toInt8 == number.int8)
        check(decoded.toInt16 == number.int16)
        check(decoded.toInt32 == number.int32)
        check(decoded.toInt64 == number.int64)

    test "decode negative integer #1":
        const data = encodeHead(NegInt, 11)
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == true)
        check(decoded.intVal == 11)
        const number = -12'i64
        check(decoded.toInt8 == number.int8)
        check(decoded.toInt16 == number.int16)
        check(decoded.toInt32 == number.int32)
        check(decoded.toInt64 == number.int64)

    test "decode negative integer #2":
        const data = encodeHead(NegInt, 25000)
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == true)
        check(decoded.intVal == 25000)
        const number = -25001'i64
        check(decoded.toInt16 == number.int16)
        check(decoded.toInt32 == number.int32)
        check(decoded.toInt64 == number.int64)

    test "decode negative integer #3":
        const data = encodeHead(NegInt, 69420)
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == true)
        check(decoded.intVal == 69420)
        const number = -69421'i64
        check(decoded.toInt32 == number.int32)
        check(decoded.toInt64 == number.int64)
