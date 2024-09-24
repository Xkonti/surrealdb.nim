import std/[sequtils, unittest]
import surreal/private/types/[surrealTypes, surrealValue]

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
