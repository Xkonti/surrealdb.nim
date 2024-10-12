import std/unittest
import surreal/private/cbor/[decoder, encoder, types, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Decoder:Integer":

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

    test "decode CBOR reference integers":
        # https://www.rfc-editor.org/rfc/rfc8949.html#name-examples-of-encoded-cbor-da

        var writer = newCborWriter()
        var decoded: SurrealValue

        decoded = decode(@[0x00'u8])
        check(decoded.kind == SurrealInteger)
        check(decoded.isPositive)
        check(decoded.toInt8 == 0)

        decoded = decode(@[0x01'u8])
        check(decoded.kind == SurrealInteger)
        check(decoded.isPositive)
        check(decoded.toInt8 == 1)

        decoded = decode(@[0x0a'u8])
        check(decoded.kind == SurrealInteger)
        check(decoded.isPositive)
        check(decoded.toInt8 == 10)

        decoded = decode(@[0x17'u8])
        check(decoded.kind == SurrealInteger)
        check(decoded.isPositive)
        check(decoded.toInt8 == 23)

        decoded = decode(@[0x18'u8, 0x18])
        check(decoded.kind == SurrealInteger)
        check(decoded.isPositive)
        check(decoded.toInt8 == 24)

        decoded = decode(@[0x18'u8, 0x19])
        check(decoded.kind == SurrealInteger)
        check(decoded.isPositive)
        check(decoded.toInt8 == 25)

        decoded = decode(@[0x18'u8, 0x64])
        check(decoded.kind == SurrealInteger)
        check(decoded.isPositive)
        check(decoded.toInt8 == 100)

        decoded = decode(@[0x19'u8, 0x03, 0xe8])
        check(decoded.kind == SurrealInteger)
        check(decoded.isPositive)
        check(decoded.toInt16 == 1000)

        decoded = decode(@[0x1a'u8, 0x00, 0x0f, 0x42, 0x40])
        check(decoded.kind == SurrealInteger)
        check(decoded.isPositive)
        check(decoded.toInt32 == 1000000)

        decoded = decode(@[0x1b'u8, 0x00, 0x00, 0x00, 0xe8, 0xd4, 0xa5, 0x10, 0x00])
        check(decoded.kind == SurrealInteger)
        check(decoded.isPositive)
        check(decoded.toInt64 == 1000000000000'i64)

        decoded = decode(@[0x1b'u8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
        check(decoded.kind == SurrealInteger)
        check(decoded.isPositive)
        check(decoded.toUInt64 == 18446744073709551615'u64)

        # BIGINT?
        # decoded = decode(@[0xc2'u8, 0x49, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        # check(decoded.kind == SurrealInteger)
        # check(decoded.isPositive)
        # check(decoded.toUInt64 == 18446744073709551616'u64)

        # decoded = decode(@[0x3b'u8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
        # check(decoded.kind == SurrealInteger)
        # check(not decoded.isPositive)
        # check(decoded.toInt64 == -18446744073709551616)

        # decoded = decode(@[0xc3'u8, 0x49, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        # check(decoded.kind == SurrealInteger)
        # check(decoded.isPositive)
        # check(decoded.toInt64 == -18446744073709551617)

        decoded = decode(@[0x20'u8])
        check(decoded.kind == SurrealInteger)
        check(not decoded.isPositive)
        check(decoded.toInt8 == -1)

        decoded = decode(@[0x29'u8])
        check(decoded.kind == SurrealInteger)
        check(not decoded.isPositive)
        check(decoded.toInt8 == -10)

        decoded = decode(@[0x38'u8, 0x63])
        check(decoded.kind == SurrealInteger)
        check(not decoded.isPositive)
        check(decoded.toInt8 == -100)

        decoded = decode(@[0x39'u8, 0x03, 0xe7])
        check(decoded.kind == SurrealInteger)
        check(not decoded.isPositive)
        check(decoded.toInt16 == -1000)