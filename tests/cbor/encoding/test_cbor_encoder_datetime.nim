import std/[times, unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Encoder:DateTime":

    test "Should encode current datetime":
        # TODO: Redo tests after getting proper test data
        let dtValue = dateTime(
            year = 2024, month = mSep, monthday = 27,
            hour = 22, minute = 33,
            second = 15, nanosecond = 0,
            zone = utc())
        let bytes = encode(%%% dtValue).getOutput()
        check(bytes == @[0b110_00000'u8, 0b011_10100'u8, 0x32, 0x30, 0x32, 0x34, 0x2d, 0x30, 0x39, 0x2d, 0x32, 0x37, 0x54, 0x32, 0x32, 0x3a, 0x33, 0x33, 0x3a, 0x31, 0x35, 0x5a])
