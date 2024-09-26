import std/[sequtils, unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Encoder:Bytes":

    test "Should encode an empty byte sequence":
        const value1: seq[uint8] = @[]
        let bytes = encode(%%% value1).getOutput()
        check(bytes == @[0b010_00000'u8]) # Bytes - 0 elements

    test "Should encode a single byte sequence":
        const value1: seq[uint8] = @[25]
        let bytes = encode(%%% value1).getOutput()
        check(bytes == @[0b010_00001'u8, 25]) # Bytes - 1 element

    test "Should encode a multiple byte sequence":
        const value1: seq[uint8] = @[25, 0, 1, 23, 24, 28, 31, 255, 127, 0, 0]
        let bytes = encode(%%% value1).getOutput()
        check(bytes == @[0b010_01011'u8, 25, 0, 1, 23, 24, 28, 31, 255, 127, 0, 0])

        const value2: seq[uint8] = (1'u8..23'u8).toSeq
        let bytes2 = encode(%%% value2).getOutput()
        check(bytes2 == @[0b010_10111'u8] & value2)

        const value3: seq[uint8] = (1'u8..24'u8).toSeq
        let bytes3 = encode(%%% value3).getOutput()
        check(bytes3 == @[0b010_11000'u8, 0x18] & value3)

        const value4: seq[uint8] = (0'u8..254'u8).toSeq # 255 is a max value for uint8
        let bytes4 = encode(%%% value4).getOutput()
        check(bytes4 == @[0b010_11000'u8, 0xFF] & value4)

        var value5: seq[uint8] = (0'u8..255'u8).toSeq
        for i in 0..10000:
            value5.add((i mod 250).uint8)
        let bytes5 = encode(%%% value5).getOutput()
        check(bytes5.len == value5.len + 3)
        check(bytes5 == @[0b010_11001'u8, 0x28, 0x11] & value5)