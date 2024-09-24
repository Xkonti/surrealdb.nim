import std/[sequtils, unittest]
import surreal/private/types/[surrealTypes, surrealValue]

suite "SurrealValue:String":

    test "Can create from an empty string":
        const value = ""
        let surrealValue = value.toSurrealString()
        check(surrealValue.kind == SurrealString)
        check(surrealValue.len == 0)
        check($surrealValue == value)
        check(%%%value == surrealValue)

    test "Can create from a string":
        const value = "As large as worlds. As old as Time. As patient as a brick."
        let surrealValue = value.toSurrealString()
        check(surrealValue.kind == SurrealString)
        check(surrealValue.len == value.len)
        check($surrealValue == value)
        check(%%%value == surrealValue)

    test "Can create from a sequence of bytes":
        const value: seq[uint8] = @[65, 115, 32, 108, 97, 115, 101, 32, 121, 111, 117, 32, 119, 104, 101, 32, 98, 97, 114, 105, 99, 46]
        let surrealValue = value.toSurrealString()
        check(surrealValue.kind == SurrealString)
        check(surrealValue.len == value.len)
        check(surrealValue.toBytes == value)
        check($surrealValue == cast[string](value))

    test "Can create from an array of bytes":
        const value: array[10, uint8] = [65, 115, 32, 108, 97, 115, 101, 32, 121, 111]
        let surrealValue = value.toSurrealString()
        check(surrealValue.kind == SurrealString)
        check(surrealValue.len == value.len)
        check(surrealValue.toBytes == value.toSeq)
        check($surrealValue == cast[string](value.toSeq))

    test "Can get the length of the string":
        const value = "DON'T THINK OF IT AS DYING said DEATH, THINK OF IT AS LEAVING EARLY TO AVOID THE RUSH."
        let surrealValue = value.toSurrealString()
        check(surrealValue.len == value.len)

    test "Can get the bytes of the string":
        const value = "Thunder rolled. It rolled a six."
        let surrealValue = value.toSurrealString()
        check(surrealValue.toBytes == cast[seq[uint8]](value))

    test "Can get the string value":
        const value = "The truth has got its boots on. And it's going to start kicking."
        let surrealValue = value.toSurrealString()
        check(surrealValue.getString == value)
        check($surrealValue == value)