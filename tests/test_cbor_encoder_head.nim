import std/[sequtils, unittest]
import surreal/private/stew/sequtils2
import surreal/private/cbor/[constants, encoder, reader, types, writer]
import surreal/private/utils

suite "CBOR:Encoder:Head":

    test "encodeHeadByte should properly encode the the first byte":
        check(encodeHeadByte(PosInt, Zero) == 0b000_00000'u8)
        check(encodeHeadByte(PosInt, One) == 0b000_00001'u8)
        check(encodeHeadByte(PosInt, TwoBytes) == 0b000_11001'u8)
        check(encodeHeadByte(NegInt, Zero) == 0b001_00000'u8)
        check(encodeHeadByte(NegInt, Ten) == 0b001_01010'u8)
        check(encodeHeadByte(NegInt, Indefinite) == 0b001_11111'u8)
        check(encodeHeadByte(Bytes, Six) == 0b010_00110'u8)
        check(encodeHeadByte(String, EightBytes) == 0b011_11011'u8)
        check(encodeHeadByte(Array, Reserved30) == 0b100_11110'u8)
        check(encodeHeadByte(Map, Two) == 0b101_00010'u8)
        check(encodeHeadByte(Tag, Seven) == 0b110_00111'u8)
        check(encodeHeadByte(Simple, Eight) == 0b111_01000'u8)
        check(encodeHeadByte(Simple, Indefinite) == 0b111_11111'u8)
        check(cborBreak == 0b111_11111'u8)

    test "encodeHead should properly encode the major":
        var numbers: seq[uint64] = @[]
        numbers.write (0'u64..7'u64).toSeq
        numbers.write [255'u64, 256'u64, 257'u64, uint16.high.uint64, uint32.high.uint64, uint64.high.uint64]

        for argument in numbers:
            var head = encodeHead(PosInt, argument)
            check((head[0] and 0b111_00000'u8) == 0b000_00000'u8)
            head = encodeHead(NegInt, argument)
            check((head[0] and 0b111_00000'u8) == 0b001_00000'u8)
            head = encodeHead(Bytes, argument)
            check((head[0] and 0b111_00000'u8) == 0b010_00000'u8)
            head = encodeHead(String, argument)
            check((head[0] and 0b111_00000'u8) == 0b011_00000'u8)
            head = encodeHead(Array, argument)
            check((head[0] and 0b111_00000'u8) == 0b100_00000'u8)
            head = encodeHead(Map, argument)
            check((head[0] and 0b111_00000'u8) == 0b101_00000'u8)
            head = encodeHead(Tag, argument)
            check((head[0] and 0b111_00000'u8) == 0b110_00000'u8)
            head = encodeHead(Simple, argument)
            check((head[0] and 0b111_00000'u8) == 0b111_00000'u8)

    test "encodeHead should properly encode the argument":
        for major in PosInt..Simple:
            for argument in Zero..TwentyThree:
                let head = encodeHead(major, argument.uint64)
                let expectedFirstByte = encodeHeadByte(major, argument)
                check(head[0] == expectedFirstByte)
                check(head.len == 1)

        check(encodeHead(PosInt, 24) == @[0b000_11000'u8, 0b0001_1000])
        check(encodeHead(Bytes, 25) == @[0b010_11000'u8, 0b0001_1001])
        check(encodeHead(String, 100) == @[0b011_11000'u8, 0b0110_0100])
        check(encodeHead(NegInt, 255) == @[0b001_11000'u8, 0xFF])
        check(encodeHead(Array, 256) == @[0b100_11001'u8, 0x01, 0x00])
        check(encodeHead(Map, 10_000) == @[0b101_11001'u8, 0x27, 0x10])
        check(encodeHead(Map, uint16.high.uint64) == @[0b101_11001'u8, 0xFF, 0xFF])
        check(encodeHead(Tag, uint16.high.uint64 + 1) == @[0b110_11010'u8, 0x00, 0x01, 0x00, 0x00])
        check(encodeHead(Simple, 1_000_000_000) == @[0b111_11010'u8, 0x3B, 0x9A, 0xCA, 0x00])
        check(encodeHead(Bytes, uint32.high.uint64) == @[0b010_11010'u8, 0xFF, 0xFF, 0xFF, 0xFF])
        check(encodeHead(Simple, uint32.high.uint64 + 1) == @[0b111_11011'u8, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00])
        check(encodeHead(Tag, 6_942_069_420_694_206_942'u64) == @[0b110_11011'u8, 0x60, 0x57, 0x2F, 0x5B, 0x82, 0x94, 0x79, 0xDE])
        check(encodeHead(NegInt, uint64.high) == @[0b001_11011'u8, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
