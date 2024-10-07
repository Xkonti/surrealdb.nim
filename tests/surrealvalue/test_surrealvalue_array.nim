import std/[sequtils, unittest]
import surreal/private/types/[surrealValue]

suite "SurrealValue:Array":

    test "Can create an empty array":
        let surrealValue = newSurrealArray()
        check(surrealValue.kind == SurrealArray)
        check(surrealValue.len == 0)
        check(surrealValue.getSeq.len == 0)

    test "Can be created from an empty sequence":
        let sequence: seq[SurrealValue] = @[]
        let surrealValue = sequence.toSurrealArray()
        check(surrealValue.kind == SurrealArray)
        check(surrealValue.len == 0)
        check(surrealValue.getSeq.len == 0)

    test "Can be created from a sequence of SurrealValues":
        let data: seq[SurrealValue] = @[
            %%% "Hello",
            %%% 12,
            %%% @[1'u8, 2, 3, 4, 5],
            %%% "There"
        ]
        let surrealValue = data.toSurrealArray()
        check(surrealValue.kind == SurrealArray)
        check(surrealValue.len == data.len)
        check(surrealValue.getSeq == data)
        check(%%%data == surrealValue)



    test "Can be created from an array of SurrealValues":
        let data: array[4, SurrealValue] = [
            %%% "Hello",
            %%% 12,
            %%% @[1'u8, 2, 3, 4, 5],
            %%% "There"
        ]
        let surrealValue = data.toSurrealArray()
        check(surrealValue.kind == SurrealArray)
        check(surrealValue.len == data.len)
        check(surrealValue.getSeq == data)
        check(%%%data == surrealValue)

    test "Can get the length of the array":
        let data: seq[SurrealValue] = @[%%% "Hello", %%% "There!"]
        let surrealValue = data.toSurrealArray()
        check(surrealValue.len == data.len)

    test "Can extract the sequence from the array":
        let data: seq[SurrealValue] = @[%%% "Hello", %%% "There!"]
        let surrealValue = data.toSurrealArray()
        check(surrealValue.getSeq == data)
        check(surrealValue.getSeq.len == data.len)

    test "Can add a single value to the array":
        var surrealValue = newSurrealArray()
        check(surrealValue.len == 0)
        surrealValue.add("Hello")
        check(surrealValue.len == 1)
        check(surrealValue.getSeq[0] == %%% "Hello")
        surrealValue.add(12)
        check(surrealValue.len == 2)
        check(surrealValue.getSeq[1] == %%% 12)
        surrealValue.add(@[1'u8, 2, 3, 4, 5])
        check(surrealValue.len == 3)
        check(surrealValue.getSeq[2] == %%% @[1'u8, 2, 3, 4, 5])

    test "Can add multiple values to the array":
        var surrealValue = newSurrealArray()
        check(surrealValue.len == 0)
        surrealValue.add("Hello", 12, @[1'u8, 2, 3, 4, 5])
        check(surrealValue.len == 3)
        check(surrealValue.getSeq[0] == %%% "Hello")
        check(surrealValue.getSeq[1] == %%% 12)
        check(surrealValue.getSeq[2] == %%% @[1'u8, 2, 3, 4, 5])
        check(%%% @[%%% "Hello", %%% 12, %%% @[1'u8, 2, 3, 4, 5]] == surrealValue)

    test "Can compare arrays for equality":
        let data1a = %%% @[%%% "Hello", %%% "There!"]
        let data1b = %%% @[%%% "Hello", %%% "There!"]
        check(data1a == data1b)

        let data2a = %%% @[%%% "Hello", %%% -12.32'f64, %%% @[1'u8, 2, 3, 4, 5], %%% @[%%% "Oh...", %%% "Hi!"]]
        let data2b = %%% @[%%% "Hello", %%% -12.32'f64, %%% @[1'u8, 2, 3, 4, 5], %%% @[%%% "Oh...", %%% "Hi!"]]
        check(data2a == data2b)

        let data3a = %%% @[%%% -1235243332'i64, %%% { "Hello": %%% "There!" }]
        let data3b = %%% @[%%% -1235243332'i64, %%% { "Hello": %%% "There!" }]
        check(data3a == data3b)
