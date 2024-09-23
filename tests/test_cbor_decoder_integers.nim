import std/unittest
import surreal/private/cbor/[decoder, encoder, types, writer]
import surreal/private/types/[surrealTypes, surrealValue]

suite "CBOR:Decoder:Integers":

    test "decode positive integers":
        const numbers: seq[uint64] = @[0, 6, 23, 24, 500, 69420, uint32.high, uint32.high + 1, uint64.high]
        for number in numbers:
            let writer = newCborWriter()
            writer.encodeHead(PosInt, number)
            let decoded = decode(writer.getOutput())
            check(decoded.kind == SurrealInteger)
            check(decoded.isNegative == false)
            check(decoded.toUInt64 == number)

    test "decode positive embedded integer":
        const number = 9'u64
        let writer = newCborWriter()
        writer.encodeHead(PosInt, number)
        let decoded = decode(writer.getOutput())
        check(decoded.kind == SurrealInteger)
        check(decoded.isNegative == false)
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
        let writer = newCborWriter()
        writer.encodeHead(PosInt, number)
        let decoded = decode(writer.getOutput())
        check(decoded.kind == SurrealInteger)
        check(decoded.isNegative == false)
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
        let writer = newCborWriter()
        writer.encodeHead(PosInt, number)
        let decoded = decode(writer.getOutput())
        check(decoded.kind == SurrealInteger)
        check(decoded.isNegative == false)
        check(decoded.toUInt64 == number)


    test "decode negative integers":
        const numbers: seq[uint64] = @[0, 6, 23, 24, 500, 69420, uint32.high, uint32.high + 1, int64.high.uint64]
        for number in numbers:
            let writer = newCborWriter()
            writer.encodeHead(NegInt, number)
            let decoded = decode(writer.getOutput())
            check(decoded.kind == SurrealInteger)
            check(decoded.isNegative == true)
            check(decoded.toInt64 == -number.int64 - 1)


    test "decode negative integer #0":
        let writer = newCborWriter()
        writer.encodeHead(NegInt, 0)
        let decoded = decode(writer.getOutput())
        check(decoded.kind == SurrealInteger)
        check(decoded.isNegative == true)
        const number = -1'i64
        check(decoded.toInt8 == number.int8)
        check(decoded.toInt16 == number.int16)
        check(decoded.toInt32 == number.int32)
        check(decoded.toInt64 == number.int64)

    test "decode negative integer #1":

        let writer = newCborWriter()
        writer.encodeHead(NegInt, 11)
        let decoded = decode(writer.getOutput())
        check(decoded.kind == SurrealInteger)
        check(decoded.isNegative == true)
        const number = -12'i64
        check(decoded.toInt8 == number.int8)
        check(decoded.toInt16 == number.int16)
        check(decoded.toInt32 == number.int32)
        check(decoded.toInt64 == number.int64)

    test "decode negative integer #2":
        let writer = newCborWriter()
        writer.encodeHead(NegInt, 25000)
        let decoded = decode(writer.getOutput())
        check(decoded.kind == SurrealInteger)
        check(decoded.isNegative == true)
        const number = -25001'i64
        check(decoded.toInt16 == number.int16)
        check(decoded.toInt32 == number.int32)
        check(decoded.toInt64 == number.int64)

    test "decode negative integer #3":
        let writer = newCborWriter()
        writer.encodeHead(NegInt, 69420)
        let decoded = decode(writer.getOutput())
        check(decoded.kind == SurrealInteger)
        check(decoded.isNegative == true)
        const number = -69421'i64
        check(decoded.toInt32 == number.int32)
        check(decoded.toInt64 == number.int64)
