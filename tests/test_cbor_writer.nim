import std/[unittest]
import surreal/private/cbor/[writer]

suite "CBOR:Writer":

    test "Can create a new CborWriter":
        let writer = newCborWriter()
        check writer.len == 0
        let output = writer.getOutput()
        check output.len == 0

    test "Can check writer's content length in bytes":
        let writer = newCborWriter()
        check writer.len == 0
        writer.writeRawUInt(0'u8)
        check writer.len == 1
        writer.writeRawUInt(1'u16)
        check writer.len == 3
        writer.writeRawUInt(2'u32)
        check writer.len == 7
        writer.writeRawUInt(4'u64)
        check writer.len == 15
        writer.writeRawUInt(5'u64)
        check writer.len == 23

    test "Can get writer's content":
        let writer = newCborWriter()
        check writer.getOutput().len == 0
        writer.writeRawUInt(0'u8)
        check writer.getOutput() == @[0'u8]
        writer.writeRawUInt(1'u16)
        check writer.getOutput() == @[0'u8, 0, 1]
        writer.writeRawUInt(2'u32)
        check writer.getOutput() == @[0'u8, 0, 1, 0, 0, 0, 2]
        writer.writeRawUInt(4'u64)
        check writer.getOutput() == @[0'u8, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 4]
        writer.writeRawUInt(5'u8)
        check writer.getOutput() == @[0'u8, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 4, 5]

    test "writeRawUInt into seq adds proper uint8 values":
        var data: seq[uint8] = @[]
        for value in 0..<500:
            data.add((value mod 256).uint8)

        let writer = newCborWriter()
        for value in 0..<500:
            writer.writeRawUInt(value.uint8)

        check(writer.getOutput() == data)

    test "writeRawUInt into seq adds proper uint16 values":
        const data: seq[uint16] = @[0, 30, 255, 256, 300, 9000, uint16.high]
        let writer = newCborWriter()
        for value in data:
            writer.writeRawUInt(value.uint16)

        check(writer.getOutput() == @[
            0'u8, 0'u8, # 0
            0x00, 0x1E, # 30
            0x00, 0xFF, # 255
            0x01, 0x00, # 256
            0x01, 0x2C, # 300
            0x23, 0x28, # 9000
            0xFF, 0xFF, # uint16.high
        ])

    test "writeRawUInt into seq adds proper uint32 values":
        const data: seq[uint32] = @[
            0, 42, 255, # uint8
            256, 9001, uint16.high, # uint16
            uint16.high.uint32 + 1'u32, 200_000_000, uint32.high # uint32
        ]
        let writer = newCborWriter()
        for value in data:
            writer.writeRawUInt(value.uint32)

        check(writer.getOutput() == @[
            0'u8, 0'u8, 0'u8, 0'u8, # 0
            0x00, 0x00, 0x00, 0x2A, # 42
            0x00, 0x00, 0x00, 0xFF, # 255
            0x00, 0x00, 0x01, 0x00, # 256
            0x00, 0x00, 0x23, 0x29, # 9001
            0x00, 0x00, 0xFF, 0xFF, # uint16.high
            0x00, 0x01, 0x00, 0x00, # uint16.high + 1
            0x0B, 0xEB, 0xC2, 0x00, # 200_000_000
            0xFF, 0xFF, 0xFF, 0xFF, # uint32.high
        ])

    test "writeRawUInt into seq adds proper uint64 values":
        const data: seq[uint64] = @[
            0, 42, 255, # uint8
            256, 9001, uint16.high, # uint16
            uint16.high.uint64 + 1'u64, 200_000_000, uint32.high, # uint32
            uint32.high.uint64 + 1'u64, 9_173_826_450_147_963_789'u64, uint64.high # uint64
        ]

        let writer = newCborWriter()
        for value in data:
            writer.writeRawUInt(value.uint64)

        check(writer.getOutput() == @[
            0'u8, 0'u8, 0'u8, 0'u8, 0'u8, 0'u8, 0'u8, 0'u8, # 0
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2A, # 42
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, # 255
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, # 256
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x23, 0x29, # 9001
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, # uint16.high
            0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, # uint16.high + 1
            0x00, 0x00, 0x00, 0x00, 0x0B, 0xEB, 0xC2, 0x00, # 200_000_000
            0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, # uint32.high
            0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, # uint32.high + 1
            0x7F, 0x4F, 0xFA, 0x8D, 0x28, 0x26, 0xF3, 0x8D, # 9_173_826_450_147_963_789
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, # uint64.high
        ])

    test "writeBytes adds proper byte sequence":
        const data1: seq[uint8] = @[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        let writer1 = newCborWriter()
        writer1.writeBytes(data1)
        check(writer1.getOutput() == data1)

        const data2: seq[uint8] = @[255, 254, 253, 252, 251, 250, 249, 248, 247, 246, 245, 244, 243, 242, 241, 240]
        let writer2 = newCborWriter()
        writer2.writeBytes(data2)
        check(writer2.getOutput() == data2)

        let writer3 = newCborWriter()
        writer3.writeBytes(data1)
        writer3.writeBytes(data2)
        check(writer3.getOutput() == data1 & data2)