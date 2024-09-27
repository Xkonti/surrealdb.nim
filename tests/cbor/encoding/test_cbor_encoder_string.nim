import std/[unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Encoder:String":

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