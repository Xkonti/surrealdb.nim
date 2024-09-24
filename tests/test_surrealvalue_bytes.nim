import std/[sequtils, unittest]
import surreal/private/types/[surrealTypes, surrealValue]

suite "SurrealValue:Bytes":

    test "Can be created from empty bytes":
        const sequence: seq[uint8] = @[]
        var surrealValue = sequence.toSurrealBytes()
        check(surrealValue.kind == SurrealBytes)
        check(surrealValue.len == 0)

        const array: array[0, uint8] = []
        surrealValue = array.toSurrealBytes()
        check(surrealValue.kind == SurrealBytes)
        check(surrealValue.len == 0)

        const text = ""
        surrealValue = text.toSurrealBytes()
        check(surrealValue.kind == SurrealBytes)
        check(surrealValue.len == 0)

    test "Can be created from a sequence of bytes":
        const data: seq[uint8] = @[68, 100, 25, 24, 200, 13, 157, 7, 91, 20, 13, 54, 69, 42]
        let surrealValue = data.toSurrealBytes()
        check(surrealValue.kind == SurrealBytes)
        check(surrealValue.len == data.len)
        check(surrealValue.getBytes == data)
        check(%%%data == surrealValue)

    test "Can be created from an array of bytes":
        const data = [68'u8, 100, 25, 24, 200, 13, 157, 7, 80, 91, 20, 13, 54, 69, 42]
        let surrealValue = data.toSurrealBytes()
        check(surrealValue.kind == SurrealBytes)
        check(surrealValue.len == data.len)
        check(surrealValue.getBytes == data.toSeq)
        check(%%%data == surrealValue)

    test "Can be created from a string":
        const data = "You shall not pass!"
        let surrealValue = data.toSurrealBytes()
        check(surrealValue.kind == SurrealBytes)
        check(surrealValue.len == data.len)
        check(surrealValue.getBytes == cast[seq[uint8]](data))

    test "Can get the byte array value":
        const data: seq[uint8] = @[68, 100, 25, 24, 200, 13, 157, 7, 80, 91, 20, 13, 54, 69, 42]
        let surrealValue = data.toSurrealBytes()
        check(surrealValue.getBytes == data)

    test "Can get the length of the byte array":
        const data: seq[uint8] = @[68, 100, 25, 24, 200, 13, 157, 7, 80, 91, 20, 13, 54, 69, 42]
        let surrealValue = data.toSurrealBytes()
        check(surrealValue.len == data.len)