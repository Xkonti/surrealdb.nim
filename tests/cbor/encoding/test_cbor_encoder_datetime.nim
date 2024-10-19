import std/[times, unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Encoder:DateTime":

    test "Should encode datetime without nanoseconds":
        let dtValue = dateTime(
            year = 2024, month = mSep, monthday = 27,
            hour = 22, minute = 33,
            second = 15, nanosecond = 0,
            zone = utc())
        let bytes = encode(%%% dtValue).getOutput()
        check(bytes == @[0b110_01100'u8, 0b100_00010, 0b000_11010'u8, 0x66, 0xF7, 0x32, 0xAB, 0b000_00000])

    test "Should encode datetime with nanoseconds":
        let dtValue = dateTime(
            year = 1982, month = mJan, monthday = 3,
            hour = 12, minute = 31,
            second = 1, nanosecond = 200_001_248,
            zone = utc())
        let bytes = encode(%%% dtValue).getOutput()
        check(bytes == @[0b110_01100'u8, 0b100_00010, 0b000_11010'u8, 0x16, 0x95, 0xB1, 0x85, 0b000_11010'u8, 0x0B, 0xEB, 0xC6, 0xE0])
