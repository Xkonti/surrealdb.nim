import std/[unittest]
import surreal/private/cbor/[decoder, encoder, writer]
import surreal/private/types/[surrealValue, null]

suite "CBOR:Encoding":

    test "encode and decode true":
        let writer = encode(%%% true)
        let surrealValue = decode(writer.getOutput())
        check(surrealValue.kind == SurrealBool)
        check(surrealValue.getBool == true)

    test "encode and decode false":
        let writer = encode(%%% false)
        let surrealValue = decode(writer.getOutput())
        check(surrealValue.kind == SurrealBool)
        check(surrealValue.getBool == false)

    test "encode and decode null":
        let writer = encode(%%% Null)
        let surrealValue = decode(writer.getOutput())
        check(surrealValue.kind == SurrealNull)
        check(surrealValue == surrealNull)

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

    test "Should encode and decode an array":
        let value1: seq[SurrealValue] = @[]
        let writer1 = encode(%%% value1)
        let surrealValue1 = decode(writer1.getOutput())
        check(surrealValue1.kind == SurrealArray)
        check(surrealValue1.len == 0)
        check(surrealValue1.getSeq == value1)

        let value2: seq[SurrealValue] = @[%%% 8]
        let writer2 = encode(%%% value2)
        let surrealValue2 = decode(writer2.getOutput())
        check(surrealValue2.kind == SurrealArray)
        check(surrealValue2.len == 1)
        check(surrealValue2.getSeq == value2)

        let value3: seq[SurrealValue] = @[%%% 8, %%% "Hi!"]
        let writer3 = encode(%%% value3)
        let surrealValue3 = decode(writer3.getOutput())
        check(surrealValue3.kind == SurrealArray)
        check(surrealValue3.len == 2)
        check(surrealValue3.getSeq == value3)

        let value4: seq[SurrealValue] = @[%%% -3000, %%% @[3'u8, 5, 90], %%% true, %%% 90_000_000]
        let writer4 = encode(%%% value4)
        let surrealValue4 = decode(writer4.getOutput())
        check(surrealValue4.kind == SurrealArray)
        check(surrealValue4.len == 4)
        check(surrealValue4.getSeq == value4)

        var value5: seq[SurrealValue] = @[]
        for i in 0..2000:
            value5.add(%%% i)
        value5.add(%%% "Hello")
        value5.add(%%% false)
        value5.add(%%% @[1'u8, 2, 3, 4, 5])
        value5.add(%%% @[%%% "Hello", %%% 12, %%% @[1'u8, 2, 3, 4, 5], %%% @[%%% 1, %%% 2, %%% 3]])
        let writer5 = encode(%%% value5)
        let surrealValue5 = decode(writer5.getOutput())
        check(surrealValue5.kind == SurrealArray)
        check(surrealValue5.len == 2005)
        check(surrealValue5.getSeq == value5)

    test "Should encode and decode an object":
        let value1 = %%% {
            "id": %%% "post:first",
            "author": %%% "user:10223547",
            "roles": %%% @[%%% "admin", %%% "guest"]
        }
        let writer1 = encode(value1)
        let surrealValue1 = decode(writer1.getOutput())
        check(surrealValue1.kind == SurrealObject)
        check(surrealValue1.len == 3)
        check(surrealValue1 == value1)

        let value2 = %%% {
            "id": %%% "comment:abc123",
            "author": %%% 10223547,
            "content": %%% "Happy thoughts",
            "approved": %%% true,
            "likes": %%% {
                "user:10223547": %%% 1,
                "user:10223548": %%% 2,
                "user:10223549": %%% 30
            },
            "secretFlags": %%% @[1'u8, 2, 4, 50]
        }
        let writer2 = encode(value2)
        let surrealValue2 = decode(writer2.getOutput())
        check(surrealValue2.kind == SurrealObject)
        check(surrealValue2.len == 6)
        check(surrealValue2 == value2)