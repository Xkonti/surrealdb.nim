import std/unittest
import ../src/surreal/private/cbor/[decoder, reader, types]
import ../src/surreal/private/types/[surrealTypes]

suite "CBOR:Reader:Head":

    test "head should return correct major and argument #1":
        let reader = newCborReader(@[
            0b000_00001'u8
            ])

        let (major, argument) = reader.readHead()
        check(major == 0)
        check(argument == 1)

        let fullArgument = reader.getFullArgument(argument)
        check(fullArgument == 1)

    test "head should return correct major and argument #2":
        let reader = newCborReader(@[
            0b001_01001'u8
            ])

        let (major, argument) = reader.readHead()
        check(major == 1)
        check(argument == 9)

        let fullArgument = reader.getFullArgument(argument)
        check(fullArgument == 9)

    test "head should return correct major and argument #3":
        let reader = newCborReader(@[
            0b101_11001'u8,
            0b0000_0001'u8,
            0b1111_0100'u8
            ])

        let (major, argument) = reader.readHead()
        check(major == 5)
        check(argument == 25)

        let fullArgument = reader.getFullArgument(argument)
        check(fullArgument == 500)

    test "isBreak should return true for break":
        let reader = newCborReader(@[
            0b111_11111'u8
            ])
        let head = reader.readHead()
        let isBreak = reader.isBreak(head)
        check(isBreak == true)

    test "isBreak should return false for not break":
        let reader = newCborReader(@[
            0b110_11011'u8
            ])
        let head = reader.readHead()
        let isBreak = reader.isBreak(head)
        check(isBreak == false)

    test "decode positive integer #1":
        discard

    test "decode negative integer #1":
        discard