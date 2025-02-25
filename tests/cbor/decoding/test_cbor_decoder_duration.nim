import std/[unittest]
import surreal/private/cbor/[decoder]
import surreal/private/types/[duration, surrealValue]

suite "CBOR:Decoder:Duration":

    test "decode compact duration":
        # Duration encoded as an array of 2 numbers: seconds and nanoseconds
        var decoded = decode(@[0b110_01110'u8, 0b100_00010, 0b000_11010'u8, 0x00, 0x27, 0x8E, 0x2C, 0b000_11010'u8, 0x01, 0xC9, 0xC3, 0x80])
        check(decoded.kind == SurrealDuration)
        check(decoded == "30d5m30ms".toSurrealValueDuration())

        decoded = decode(@[0b110_01110'u8, 0b100_00010, 0b000_11001'u8, 0x46, 0x6F, 0b000_11001'u8, 0xEA, 0x60])
        check(decoded.kind == SurrealDuration)
        check(decoded == "5h31s60us".toSurrealValueDuration())

    test "decode string duration":
        # Duration encoded as a string
        # 5m3h40ns
        var decoded = decode(@[0b110_01101'u8, 0b011_01000, 0x35, 0x6d, 0x33, 0x68, 0x34, 0x30, 0x6e, 0x73])
        check(decoded.kind == SurrealDuration)
        check(decoded == "5m3h40ns".toSurrealValueDuration())
        # 345120μs1s5w3s
        decoded = decode(@[0b110_01101'u8, 0b011_01111, 0x33, 0x34, 0x35, 0x31, 0x32, 0x30, 0xce, 0xbc, 0x73, 0x31, 0x73, 0x35, 0x77, 0x33, 0x73])
        check(decoded.kind == SurrealDuration)
        check(decoded == "345120μs1s5w3s".toSurrealValueDuration())
        # check(decoded == "5w4s345120µs".toSurrealValueDuration())
