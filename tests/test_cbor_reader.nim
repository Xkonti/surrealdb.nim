import std/unittest
import ../src/surreal/private/cbor/[constants, decoder, reader, types]
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
        let isBreak = head.isBreak
        check(isBreak == true)

    test "isBreak should return false for not break":
        let reader = newCborReader(@[
            0b110_11011'u8
            ])
        let head = reader.readHead()
        let isBreak = head.isBreak
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

    test "decode negative integer #0":
        const data = @[0b001_00000'u8]
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == true)
        check(decoded.intVal == 0)
        check(decoded.toInt8 == -1'i8)

    test "decode negative integer #1":
        const data = @[0b001_01011'u8]
        let decoded = decode(data)
        check(decoded.kind == SurrealInteger)
        check(decoded.intIsNegative == true)
        check(decoded.intVal == 11)
        check(decoded.toInt8 == -12'i8)

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
        check(decoded.toInt32 == -25001'i32)

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
        check(decoded.toInt64 == -69421'i64)

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

    test "decode text string #1":
        const data = @[
            0b011_00010'u8,
            0b0011_1111'u8, # Character '?'
            0b0010_0001'u8, # Character '!'
        ]
        let decoded = decode(data) # Casts: cast[string](value)
        check(decoded.kind == SurrealString) # True
        check(decoded.stringVal.len == 2) # True
        check(decoded.stringVal[0] == '?') # True
        check(decoded.stringVal[1] == '!') # True
        check($decoded == "?!") # False. It evaluates to "?!�"

    test "decode text string #2":
        var data = @[
            0b011_11001'u8,
            0b0000_0010'u8,
            0b1011_1110'u8
        ]
        let text: string = "Ginger: You know what the greatest tragedy is in the whole world?... It's all the people who never find out what it is they really want to do or what it is they're really good at. It's all the sons who become blacksmiths because their fathers were blacksmiths. It's all the people who could be really fantastic flute players who grow old and die without ever seeing a musical instrument, so they become bad plowmen instead. It's all the people with talents who never even find out. Maybe they are never even born in a time when it's even possible to find out. It's all the people who never get to know what it is that they can really be. It's all the wasted chances. -- Terry Pratchett, Moving Pictures"

        for c in text:
            data.add(c.uint8)

        let decoded = decode(data)
        check(decoded.kind == SurrealString)
        check(decoded.stringVal == text)
        check($decoded == text)

    test "decode finite array #1":
        const data = @[
            0b100_00010'u8, # Array of 2 elements
            0b000_00001'u8, # Positive integer 1
            0b001_11000'u8, # Negative integer represended by 1 byte
            0b1111_1111'u8, # Integer -256
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealArray)
        check(decoded.arrayVal.len == 2)
        check(decoded.arrayVal[0].kind == SurrealInteger)
        check(decoded.arrayVal[0].intIsNegative == false)
        check(decoded.arrayVal[0].intVal == 1)
        check(decoded.arrayVal[1].kind == SurrealInteger)
        check(decoded.arrayVal[1].intIsNegative == true)
        check(decoded.arrayVal[1].intVal == 255) # SurrealValue stores negative integers as value - 1
        check(decoded.arrayVal[1].toInt16 == -256'i16) # Should be really -256

    test "decode indefinite array #1":
        const data = @[
            0b100_11111'u8, # Array of ? elements
            0b000_00011'u8, # Positive integer 3
            0b001_11000'u8, # Negative integer represended by 1 byte
            0b1111_1111'u8, # Integer -256
            0b000_00100'u8, # Positive integer 4
            cborBreak, # Break
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealArray)
        check(decoded.arrayVal.len == 3)
        check(decoded.arrayVal[0].kind == SurrealInteger)
        check(decoded.arrayVal[0].intIsNegative == false)
        check(decoded.arrayVal[0].intVal == 3)
        check(decoded.arrayVal[1].kind == SurrealInteger)
        check(decoded.arrayVal[1].intIsNegative == true)
        check(decoded.arrayVal[1].intVal == 255) # SurrealValue stores negative integers as value - 1
        check(decoded.arrayVal[1].toInt16 == -256'i16) # Should be really -256
        check(decoded.arrayVal[2].kind == SurrealInteger)
        check(decoded.arrayVal[2].intIsNegative == false)
        check(decoded.arrayVal[2].intVal == 4)

    test "decode nested indefinite array #1":
        const data = @[
            0b100_11111'u8, # Array of ? elements
            0b000_00011'u8, # Positive integer 3
            0b100_11111'u8, # Array of ? elements
            0b000_00011'u8, # Positive integer 3
            0b000_00011'u8, # Positive integer 3
            0b000_00011'u8, # Positive integer 3
            cborBreak, # Break
            0b000_00100'u8, # Positive integer 4
            cborBreak, # Break
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealArray)
        check(decoded.arrayVal.len == 3)
        check(decoded.arrayVal[0].kind == SurrealInteger)
        check(decoded.arrayVal[0].intIsNegative == false)
        check(decoded.arrayVal[0].intVal == 3)
        check(decoded.arrayVal[1].kind == SurrealArray)
        check(decoded.arrayVal[1].arrayVal.len == 3)
        check(decoded.arrayVal[1].arrayVal[0].kind == SurrealInteger)
        check(decoded.arrayVal[1].arrayVal[0].intIsNegative == false)
        check(decoded.arrayVal[1].arrayVal[0].intVal == 3)
        check(decoded.arrayVal[1].arrayVal[1].kind == SurrealInteger)
        check(decoded.arrayVal[1].arrayVal[1].intIsNegative == false)
        check(decoded.arrayVal[1].arrayVal[1].intVal == 3)
        check(decoded.arrayVal[1].arrayVal[2].kind == SurrealInteger)
        check(decoded.arrayVal[1].arrayVal[2].intIsNegative == false)
        check(decoded.arrayVal[1].arrayVal[2].intVal == 3)
        check(decoded.arrayVal[2].kind == SurrealInteger)
        check(decoded.arrayVal[2].intIsNegative == false)
        check(decoded.arrayVal[2].intVal == 4)