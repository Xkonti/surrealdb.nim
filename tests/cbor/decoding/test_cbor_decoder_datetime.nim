import std/[times, unittest]
import surreal/private/cbor/[decoder, encoder, types, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Decoder:Datetime":

    test "decode CBOR examples":
        # 0("2013-03-21T20:04:00Z")	
        var decoded = decode(@[0xc0'u8, 0x74, 0x32, 0x30, 0x31, 0x33, 0x2d, 0x30, 0x33, 0x2d, 0x32, 0x31, 0x54, 0x32, 0x30, 0x3a, 0x30, 0x34, 0x3a, 0x30, 0x30, 0x5a])
        check(decoded.kind == SurrealDatetime)
        check(decoded == dateTime(
            year = 2013, month = mMar, monthday = 21,
            hour = 20, minute = 4,
            second = 0, nanosecond = 0,
            zone = utc()).toSurrealDatetime())

    test "decode string datetimes":
        # 2024-10-18T06:02:39.021Z
        var decoded = decode(@[0xc0'u8, 0b011_11000, 24,
          0x32, 0x30, 0x32, 0x34, 0x2d, 0x31, 0x30, 0x2d, 0x31, 0x38, 0x54, 0x30, 0x36, 0x3a, 0x30, 0x32, 0x3a, 0x33, 0x39, 0x2e, 0x30, 0x32, 0x31, 0x5a
        ])
        check(decoded.kind == SurrealDatetime)
        check(decoded == dateTime(
            year = 2024, month = mOct, monthday = 18,
            hour = 6, minute = 2,
            second = 39, nanosecond = 21_000_000,
            zone = utc()).toSurrealDatetime())

        # 2023-12-12T05:24:52.051+03:00 = 2023-12-12T02:24:52.051Z
        decoded = decode(@[0xc0'u8, 0b011_11000, 29,
          0x32, 0x30, 0x32, 0x33, 0x2d, 0x31, 0x32, 0x2d, 0x31, 0x32, 0x54, 0x30, 0x35, 0x3a, 0x32, 0x34, 0x3a, 0x35, 0x32, 0x2e, 0x30, 0x35, 0x31, 0x2b, 0x30, 0x33, 0x3a, 0x30, 0x30
        ])
        check(decoded.kind == SurrealDatetime)
        check(decoded == dateTime(
            year = 2023, month = mDec, monthday = 12,
            hour = 2, minute = 24,
            second = 52, nanosecond = 51_000_000,
            zone = utc()).toSurrealDatetime())

        # 2078-01-27T18:48:53.999-11 = 2078-01-28T05:48:53.999Z
        decoded = decode(@[0xc0'u8, 0b011_11000, 26,
          0x32, 0x30, 0x37, 0x38, 0x2d, 0x30, 0x31, 0x2d, 0x32, 0x37, 0x54, 0x31, 0x38, 0x3a, 0x34, 0x38, 0x3a, 0x35, 0x33, 0x2e, 0x39, 0x39, 0x39, 0x2d, 0x31, 0x31
          ])
        check(decoded.kind == SurrealDatetime)
        check(decoded == dateTime(
            year = 2078, month = mJan, monthday = 28,
            hour = 5, minute = 48,
            second = 53, nanosecond = 999_000_000,
            zone = utc()).toSurrealDatetime())

        # 1973-03-03T14:05:00+03:00 = 1973-03-03T11:05:00.000Z
        decoded = decode(@[0xc0'u8, 0b011_11000, 25,
          0x31, 0x39, 0x37, 0x33, 0x2d, 0x30, 0x33, 0x2d, 0x30, 0x33, 0x54, 0x31, 0x34, 0x3a, 0x30, 0x35, 0x3a, 0x30, 0x30, 0x2b, 0x30, 0x33, 0x3a, 0x30, 0x30
        ])
        check(decoded.kind == SurrealDatetime)
        check(decoded == dateTime(
            year = 1973, month = mMar, monthday = 3,
            hour = 11, minute = 5,
            second = 0, nanosecond = 0,
            zone = utc()).toSurrealDatetime())

    test "decode compact datetime without nanoseconds":
        # 2024-10-18T06:02:39Z
        var decoded = decode(@[
            204'u8, 130, # Tag 12 (datetime), array with 2 elements
            0b000_11010'u8, 0x67, 0x11, 0xF9, 0xFF, # 1729231359 - seconds since epoch
            0b000_00000'u8 # 0 - nanoseconds
        ])
        check(decoded.kind == SurrealDatetime)
        check(decoded == dateTime(
            year = 2024, month = mOct, monthday = 18,
            hour = 6, minute = 2,
            second = 39, nanosecond = 0,
            zone = utc()).toSurrealDatetime())

    test "decode compact datetime with nanoseconds":
        # 2078-01-28T05:48:53.999Z
        var decoded = decode(@[
            204'u8, 130, # Tag 12 (datetime), array with 2 elements
            0b000_11010'u8, 0xCB, 0x49, 0x3C, 0xC5, # 1729231359 - seconds since epoch
            0b000_11010'u8, 0x3B, 0x8B, 0x87, 0xC0, # 999_000_000 - nanoseconds
        ])
        check(decoded.kind == SurrealDatetime)
        check(decoded == dateTime(
            year = 2078, month = mJan, monthday = 28,
            hour = 5, minute = 48,
            second = 53, nanosecond = 999_000_000,
            zone = utc()).toSurrealDatetime())

