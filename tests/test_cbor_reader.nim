import std/unittest
import ../src/surreal/private/cbor/[decoder, reader, types]
import ../src/surreal/private/types/[surrealTypes, surrealValue]

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
        const data = @[0b000_01001'u8]
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == false)
        check(decoded.intVal == 9)
        check(decoded.toInt16 == 9'i16)
        check(decoded.toUInt8 == 9'u8)

    test "decode positive integer #2":
        const data = @[0b000_11000'u8, 0b0100_0101'u8]
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == false)
        check(decoded.intVal == 69)
        check(decoded.toInt8 == 69'i8)
        check(decoded.toUInt16 == 69'u16)

    test "decode positive integer #3":
        const data = @[
            0b000_11011'u8,
            0b0110_0000'u8,
            0b0101_0111'u8,
            0b0010_1111'u8,
            0b0101_1011'u8,
            0b1000_0010'u8,
            0b1001_0100'u8,
            0b0111_1001'u8,
            0b1101_1110'u8
            ]
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == false)
        check(decoded.intVal == 6_942_069_420_694_206_942'u64)
        check(decoded.toUInt64 == 6_942_069_420_694_206_942'u64)

    test "decode negative integer #1":
        const data = @[0b001_01011'u8]
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == true)
        check(decoded.intVal == 11)
        check(decoded.toInt8 == -11'i8)

    test "decode negative integer #2":
        const data = @[
            0b001_11001'u8,
            0b0110_0001'u8,
            0b1010_1000'u8
            ]
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == true)
        check(decoded.intVal == 25000)
        check(decoded.toInt32 == -25000'i32)

    test "decode negative integer #3":
        const data = @[
            0b001_11010'u8,
            0b0000_0000'u8,
            0b0000_0001'u8,
            0b0000_1111'u8,
            0b0010_1100'u8
            ]
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == true)
        check(decoded.intVal == 69420)
        check(decoded.toInt64 == -69420'i64)

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