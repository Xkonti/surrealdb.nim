import std/unittest
import surreal/private/stew/sequtils2
import surreal/private/cbor/[encoder, reader, types, writer]

suite "CBOR:Reader":

    test "Returns the number of bytes left":
        const data = @[0b010_00010'u8, 0b0101_1010'u8]
        let reader = newCborReader(data)
        check(reader.getBytesLeft == 2)
        discard reader.readBytes(1)
        check(reader.getBytesLeft == 1)
        discard reader.readBytes(1)
        check(reader.getBytesLeft == 0)

    test "Checks if has reached the end":
        const data = @[0b010_00010'u8, 0b0101_1010'u8]
        let reader = newCborReader(data)
        check(not reader.isEnd)
        discard reader.readBytes(1)
        check(not reader.isEnd)
        discard reader.readBytes(1)
        check(reader.isEnd)

    test "Properly reads uint8":
        const data = @[
            0'u8,
            1'u8,
            24'u8,
            31'u8,
            127'u8,
            128'u8,
            uint8.high.uint8 - 1'u8,
            uint8.high.uint8,
        ]
        let reader = newCborReader(data)
        for value in data:
            check(reader.readUInt8 == value)

        check(reader.isEnd)

    test "Properly reads uint16":
        const numbers: seq[uint16] = @[
            0, 30, 250, uint8.high.uint16 - 1'u16, uint8.high.uint16,
            500, 31002, uint16.high - 1, uint16.high
        ]
        var data: seq[uint8] = @[]
        for number in numbers:
            data.writeRawUInt(number)

        let reader = newCborReader(data)
        for value in numbers:
            check(reader.readUInt16 == value)

        check(reader.isEnd)

    test "Properly reads uint32":
        const numbers: seq[uint32] = @[
            0, 42, 211, uint8.high.uint32 - 1'u32, uint8.high.uint32,
            500, 31002, uint16.high.uint32 - 1'u32, uint16.high.uint32,
            2330254, uint32.high - 1, uint32.high
        ]
        var data: seq[uint8] = @[]
        for number in numbers:
            data.writeRawUInt(number)

        let reader = newCborReader(data)
        for value in numbers:
            check(reader.readUInt32 == value)

        check(reader.isEnd)

    test "Properly reads uint64":
        const numbers: seq[uint64] = @[
            0, 42, 211, uint8.high.uint64 - 1'u64, uint8.high.uint64,
            500, 31002, uint16.high.uint64 - 1'u64, uint16.high.uint64,
            2330254, uint32.high.uint64 - 1'u64, uint32.high.uint64,
            uint32.high.uint64 + 1'u64, uint64.high - 1, uint64.high
        ]
        var data: seq[uint8] = @[]
        for number in numbers:
            data.writeRawUInt(number)

        let reader = newCborReader(data)
        for value in numbers:
            check(reader.readUInt64 == value)

        check(reader.isEnd)

    test "Properly reads multiple bytes":
        const group1: seq[uint8] = @[30, 108]
        const group2: seq[uint8] = @[250, 0, 251, 55]
        const group3: seq[uint8] = @[0, 0, 255, 100, 75]

        var data: seq[uint8] = @[]
        data.write(group1)
        data.write(group2)
        data.write(group3)

        let reader = newCborReader(data)
        check(reader.readBytes(group1.len) == group1)
        check(reader.readBytes(group2.len) == group2)
        check(reader.readBytes(group3.len) == group3)
        check(reader.isEnd)

    test "head should return correct major and argument":
        for major in PosInt..Simple:
            for argument in Zero..Indefinite:
                let reader = newCborReader(@[encodeHeadByte(major, argument)])
                let (major, argument) = reader.readHead()
                check(major == major)
                check(argument == argument)

    test "head should contain correct full argument":
        for major in PosInt..Simple:
            for argument in Zero..TwentyThree:
                let reader = newCborReader(@[encodeHeadByte(major, argument)])
                let (major, argument) = reader.readHead()
                let fullArgument = reader.getFullArgument(argument)
                check(fullArgument == argument.uint64)

            const numbers: seq[uint64] = @[0, 6, 23, 24, uint8.high, uint8.high + 1, uint16.high, uint16.high + 1, uint32.high, uint32.high + 1, uint64.high]
            for number in numbers:
                let reader = newCborReader(encodeHead(major, number.uint64))
                let (major, argument) = reader.readHead()
                let fullArgument = reader.getFullArgument(argument)
                check(fullArgument == number)

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

    test "isIndefinite should return true for indefinite":
        # isIntefinite should only inspect the argument, so all major types should be fine
        var data: seq[uint8] = @[]
        for major in PosInt..Simple:
            data.add(encodeHeadByte(major, Indefinite))
        let reader = newCborReader(data)
        for i in 0..<data.len:
            let (_, argument) = reader.readHead()
            check(argument.isIndefinite)


    test "isIndefinite should return false for not indefinite":
        var data: seq[uint8] = @[]
        for major in PosInt..Simple:
            for argument in Zero..Reserved30:
                data.add(encodeHeadByte(major, argument))
        let reader = newCborReader(data)
        for i in 0..<data.len:
            let (_, argument) = reader.readHead()
            check(not argument.isIndefinite)