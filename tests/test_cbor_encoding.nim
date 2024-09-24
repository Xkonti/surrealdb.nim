import std/[sequtils, unittest]
import surreal/private/cbor/[constants, decoder, encoder, types, writer]
import surreal/private/types/[surrealTypes, surrealValue]

suite "CBOR:Encoding":

    test "Should encode and decode a single integer":
        const value1: int8 = 0
        let writer1 = encode(%%% value1)
        let surrealValue1 = decode(writer1.getOutput())
        check(surrealValue1.kind == SurrealInteger)
        check(surrealValue1.toInt8 == value1)

        const value2: int16 = -21_151
        let writer2 = encode(%%% value2)
        let surrealValue2 = decode(writer2.getOutput())
        check(surrealValue2.kind == SurrealInteger)
        check(surrealValue2.toInt16 == value2)

        const value3: int32 = 147_483_647
        let writer3 = encode(%%% value3)
        let surrealValue3 = decode(writer3.getOutput())
        check(surrealValue3.kind == SurrealInteger)
        check(surrealValue3.toInt32 == value3)

        const value4: int64 = 9_223_372_036_854_775_807
        let writer4 = encode(%%% value4)
        let surrealValue4 = decode(writer4.getOutput())
        check(surrealValue4.kind == SurrealInteger)
        check(surrealValue4.toInt64 == value4)

        const value5: int64 = int64.low
        let writer5 = encode(%%% value5)
        let surrealValue5 = decode(writer5.getOutput())
        check(surrealValue5.kind == SurrealInteger)
        check(surrealValue5.toInt64 == value5)

        const value6: uint64 = uint64.high
        let writer6 = encode(%%% value6)
        let surrealValue6 = decode(writer6.getOutput())
        check(surrealValue6.kind == SurrealInteger)
        check(surrealValue6.toUInt64 == value6)

    test "Should encode and decode a byte sequence":
        const value1: seq[uint8] = @[]
        let writer1 = encode(%%% value1)
        let surrealValue1 = decode(writer1.getOutput())
        check(surrealValue1.kind == SurrealBytes)
        check(surrealValue1.len == 0)
        check(surrealValue1.getBytes.len == 0)

        const value2: seq[uint8] = @[31]
        let writer2 = encode(%%% value2)
        let surrealValue2 = decode(writer2.getOutput())
        check(surrealValue2.kind == SurrealBytes)
        check(surrealValue2.len == 1)
        check(surrealValue2.getBytes == value2)

        const value3: seq[uint8] = @[25, 0, 1, 23, 24, 28, 31, 255, 127, 0, 0]
        let writer3 = encode(%%% value3)
        let surrealValue3 = decode(writer3.getOutput())
        check(surrealValue3.kind == SurrealBytes)
        check(surrealValue3.len == value3.len)
        check(surrealValue3.getBytes == value3)

        var value4: seq[uint8] = @[]
        for i in 0..10000:
            value4.add((i mod 255).uint8)
        let writer4 = encode(%%% value4)
        let surrealValue4 = decode(writer4.getOutput())
        check(surrealValue4.kind == SurrealBytes)
        check(surrealValue4.len == value4.len)
        check(surrealValue4.getBytes == value4)

    test "Should encode and decode a string":
        const value1: string = ""
        let writer1 = encode(%%% value1)
        let surrealValue1 = decode(writer1.getOutput())
        check(surrealValue1.kind == SurrealString)
        check(surrealValue1.len == 0)
        check(surrealValue1.getString == value1)

        const value2: string = "Howdy!"
        let writer2 = encode(%%% value2)
        let surrealValue2 = decode(writer2.getOutput())
        check(surrealValue2.kind == SurrealString)
        check(surrealValue2.len == value2.len)
        check(surrealValue2.getString == value2)

        const value3: string = "The presence of those seeking the truth is infinitely to be preferred to the presence of those who think they’ve found it."
        let writer3 = encode(%%% value3)
        let surrealValue3 = decode(writer3.getOutput())
        check(surrealValue3.kind == SurrealString)
        check(surrealValue3.len == value3.len)
        check(surrealValue3.getString == value3)