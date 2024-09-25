import std/[sequtils, unittest]
import surreal/private/stew/sequtils2
import surreal/private/cbor/[constants, encoder, types, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Encoder:Integers":

    test "Should encode a single integer":
        const value1 = 3'u64
        let bytes = encode(%%% value1).getOutput()
        check(bytes == @[0b000_00011'u8])

        const value2 = -12
        let bytes2 = encode(%%% value2).getOutput()
        check(bytes2 == @[0b001_01011'u8]) # Stores -11 due to CBOR range -1 .. -max

        const value3 = 12_355_841
        let bytes3 = encode(%%% value3).getOutput()
        check(bytes3 == @[0b000_11010'u8, 0x00, 0xBC, 0x89, 0x01])

    test "Should encode multiple integers":
        const value0 = 0
        let writer = encode(%%% value0)
        check(writer.getOutput() == @[0b000_00000'u8])

        const value1 = 3'u64
        writer.encode(%%% value1)
        check(writer.getOutput() == @[0b000_00000'u8, 0b000_00011'u8])

        const value2 = -12
        writer.encode(%%% value2)
        check(writer.getOutput() == @[0b000_00000'u8, 0b000_00011'u8, 0b001_01011'u8]) # Stores -11 due to CBOR range -1 .. -max

        const value3 = 12_355_841
        writer.encode(%%% value3)
        check(writer.getOutput() == @[0b000_00000'u8, 0b000_00011'u8, 0b001_01011'u8, 0b000_11010'u8, 0x00, 0xBC, 0x89, 0x01])