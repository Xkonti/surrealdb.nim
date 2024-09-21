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

    test "decode byte string #1":
        const data = @[
            0b010_00010'u8,
            0b0101_1010'u8,
            0b1010_0101'u8,
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealBytes)
        check(decoded.bytesVal[0] == data[1])
        check(decoded.bytesVal[1] == data[2])

    test "decode byte string #2":
        var data = @[
            0b010_11001'u8,
            0b0000_0001'u8,
            0b1111_0100'u8
        ]
        for i in 0..<500:
            let value = i mod 256
            data.add(value.uint8)

        let decoded = decode(data)
        check(decoded.kind == SurrealBytes)
        for i in 0..<500:
            let value = i mod 256
            check(decoded.bytesVal[i] == value.uint8)