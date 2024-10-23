import std/[unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Encoder:Duration":

    test "should encode duration":
        var duration = "30d5m30ms".toSurrealValueDuration()
        # seconds: 2592300 ns: 30_000_000
        var bytes = encode(duration).getOutput()
        check(bytes == @[0b110_01110'u8, 0b100_00010, 0b000_11010'u8, 0x00, 0x27, 0x8E, 0x2C, 0b000_11010'u8, 0x01, 0xC9, 0xC3, 0x80])
        
        duration = "5h31s60us".toSurrealValueDuration()
        # seconds: 18031 ns: 60_000
        bytes = encode(duration).getOutput()
        check(bytes == @[0b110_01110'u8, 0b100_00010, 0b000_11001'u8, 0x46, 0x6F, 0b000_11001'u8, 0xEA, 0x60])
