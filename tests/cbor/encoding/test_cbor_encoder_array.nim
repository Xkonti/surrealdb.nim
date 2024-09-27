import std/[unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Encoder:Array":

    test "Should encode an empty array":
        let value1: seq[SurrealValue] = @[]
        let bytes = encode(%%% value1).getOutput()
        check(bytes == @[0b100_00000'u8]) # Array - 0 elements

    test "Should encode an array with a single element":
        let value1: seq[SurrealValue] = @[%%% 8]
        let bytes = encode(%%% value1).getOutput()
        check(bytes == @[0b100_00001'u8, 0b000_01000'u8])

        let value2: seq[SurrealValue] = @[%%% "Hi!"]
        let bytes2 = encode(%%% value2).getOutput()
        check(bytes2 == @[0b100_00001'u8, 0b011_00011'u8, 0x48, 0x69, 0x21])

    test "Should encode an array with multiple elements":
        let value1: seq[SurrealValue] = @[%%% 8, %%% "Hi!"]
        let bytes = encode(%%% value1).getOutput()
        check(bytes == @[0b100_00010'u8, 0b000_01000'u8, 0b011_00011'u8, 0x48, 0x69, 0x21])

        let value2: seq[SurrealValue] = @[%%% -3000, %%% @[3'u8, 5, 90], %%% 24, %%% 90_000_000]
        let bytes2 = encode(%%% value2).getOutput()
        check(bytes2 == @[
            0b100_00100'u8, # Array with 4 elements
            0b001_11001'u8, 0x0B, 0xB7, # -3000 as NegInt 2999 (2 bytes)
            0b010_00011'u8, 3, 5 ,90, # Bytes with 3 elements
            0b000_11000'u8, 24, # 24 (1 byte)
            0b000_11010'u8, 0x05, 0x5D, 0x4A, 0x80 # 90_000_000 (4 bytes)
        ])

        var value3: seq[SurrealValue] = @[]
        for i in 0..5000:
            value3.add(%%% i)
        let bytes3 = encode(%%% value3).getOutput()

        # Check the head
        var pos = 0
        check(bytes3[0] == 0b100_11001'u8) # Array with 2 bytes as length
        check(bytes3[1] == 0x13) # First byte of the length
        check(bytes3[2] == 0x89) # First byte of the length
        pos += 3

        # Go over first 24 elements are encoded within the first byte
        check(bytes3[pos+0] == 0b000_00000'u8)
        check(bytes3[pos+1] == 0b000_00001'u8)
        check(bytes3[pos+2] == 0b000_00010'u8)
        check(bytes3[pos+3] == 0b000_00011'u8)
        check(bytes3[pos+4] == 0b000_00100'u8)
        check(bytes3[pos+5] == 0b000_00101'u8)
        check(bytes3[pos+6] == 0b000_00110'u8)
        check(bytes3[pos+7] == 0b000_00111'u8)
        check(bytes3[pos+8] == 0b000_01000'u8)
        check(bytes3[pos+9] == 0b000_01001'u8)
        check(bytes3[pos+10] == 0b000_01010'u8)
        check(bytes3[pos+11] == 0b000_01011'u8)
        check(bytes3[pos+12] == 0b000_01100'u8)
        check(bytes3[pos+13] == 0b000_01101'u8)
        check(bytes3[pos+14] == 0b000_01110'u8)
        check(bytes3[pos+15] == 0b000_01111'u8)
        check(bytes3[pos+16] == 0b000_10000'u8)
        check(bytes3[pos+17] == 0b000_10001'u8)
        check(bytes3[pos+18] == 0b000_10010'u8)
        check(bytes3[pos+19] == 0b000_10011'u8)
        check(bytes3[pos+20] == 0b000_10100'u8)
        check(bytes3[pos+21] == 0b000_10101'u8)
        check(bytes3[pos+22] == 0b000_10110'u8)
        check(bytes3[pos+23] == 0b000_10111'u8)
        pos += 24

        # Go over the 1-byte length elements
        for i in 24..255:
            check(bytes3[pos] == 0b000_11000'u8)
            check(bytes3[pos+1] == i.uint8)
            pos += 2

        # Go over the 2-byte length elements
        for i in 256'u16..5000'u16:
            check(bytes3[pos] == 0b000_11001'u8)
            check(bytes3[pos+1] == i.uint16 shr 8)
            check(bytes3[pos+2] == (i.uint16 and 0xFF.uint16).uint8)
            pos += 3

    test "Should encode an array with nested arrays":
        let value1: seq[SurrealValue] = @[
            %%% 120,
            %%% @[%%% 1, %%% 2, %%% 3, %%% 40, %%% 5],
            %%% @[%%% 6, %%% 7, %%% 809],
            %%% @[%%% 11, %%% -120]
        ]
        let bytes = encode(%%% value1).getOutput()
        check(bytes == @[
            0b100_00100'u8, # Array with 4 elements
                0b000_11000'u8, 120, # Positive integer 120
                0b100_00101'u8, # Array with 5 elements
                    0b000_00001'u8, # Positive integer 1
                    0b000_00010'u8, # Positive integer 2
                    0b000_00011'u8, # Positive integer 3
                    0b000_11000'u8, 40, # Positive integer 40
                    0b000_00101'u8, # Positive integer 5
                0b100_00011'u8, # Array with 3 elements
                    0b000_00110'u8, # Positive integer 6
                    0b000_00111'u8, # Positive integer 7
                    0b000_11001'u8, 0x03, 0x29, # Positive integer 809
                0b100_00010'u8, # Array with 2 elements
                    0b000_01011'u8, # Positive integer 11
                    0b001_11000'u8, 119, # Negative integer -120 (as 119)
        ])
