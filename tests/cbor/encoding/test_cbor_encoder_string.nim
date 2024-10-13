import std/[unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Encoder:String":

    test "encode CBOR examples":
        var bytes = encode(%%% "").getOutput()
        check(bytes == @[0x60'u8])

        bytes = encode(%%% "a").getOutput()
        check(bytes == @[0x61'u8, 0x61])

        bytes = encode(%%% "IETF").getOutput()
        check(bytes == @[0x64'u8, 0x49, 0x45, 0x54, 0x46])

        bytes = encode(%%% "\"\\").getOutput()
        check(bytes == @[0x62'u8, 0x22, 0x5c])

        bytes = encode(%%% "\u00fc").getOutput()
        check(bytes == @[0x62'u8, 0xc3, 0xbc])

        bytes = encode(%%% "\u6c34").getOutput()
        check(bytes == @[0x63'u8, 0xe6, 0xb0, 0xb4])

        # bytes = encode(%%% "\ud800\udd51").getOutput()
        # check(bytes == @[0x64'u8, 0xf0, 0x90, 0x85, 0x91])

    test "Should encode an empty string":
        const value1: string = ""
        let bytes = encode(%%% value1).getOutput()
        check(bytes == @[0b011_00000'u8]) # String - 0 elements

    test "Should encode a string":
        const value2: string = "Wololo"
        let bytes2 = encode(%%% value2).getOutput()
        check(bytes2 == @[0b011_00110'u8, 0x57, 0x6F, 0x6C, 0x6F, 0x6C, 0x6F])

        const value3: string = "Stories of imagination tend to upset those without one."
        static: doAssert value3.len <= uint8.high # Make sure the string's length fits in a uint8
        let valueBytes = cast[seq[uint8]](value3)
        let bytes3 = encode(%%% value3).getOutput()
        check(bytes3 == @[0b011_11000'u8, value3.len.uint8] & valueBytes)