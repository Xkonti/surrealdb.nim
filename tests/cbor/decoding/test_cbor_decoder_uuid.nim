import std/unittest
import surreal/private/cbor/[decoder, encoder, types, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Decoder:Uuid":

    test "decode binary uuid":
        const data = @[
            encodeHeadByte(Tag, OneByte),
            37, # Binery UUID
            encodeHeadByte(Bytes, Sixteen),
            191, 152, 22, 41, 4, 254, 190, 102, 20, 59, 164, 85, 1, 0, 255, 35
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealUuid)
        let bytes = decoded.getUuid
        check(bytes == @[191'u8, 152, 22, 41, 4, 254, 190, 102, 20, 59, 164, 85, 1, 0, 255, 35])

    test "decode string uuid":
        const data = @[
            encodeHeadByte(Tag, Nine),
            encodeHeadByte(String, OneByte),
            36, # String length
            # 7839e750-4641-4cfa-8dea-449375145be3
            0x37, 0x38, 0x33, 0x39, 0x65, 0x37, 0x35, 0x30, 0x2d, 0x34, 0x36, 0x34,
            0x31, 0x2d, 0x34, 0x63, 0x66, 0x61, 0x2d, 0x38, 0x64, 0x65, 0x61, 0x2d,
            0x34, 0x34, 0x39, 0x33, 0x37, 0x35, 0x31, 0x34, 0x35, 0x62, 0x65, 0x33
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealUuid)
        let bytes = decoded.getUuid
        check(bytes == @[120'u8, 57, 231, 80, 70, 65, 76, 250, 141, 234, 68, 147, 117, 20, 91, 227])
