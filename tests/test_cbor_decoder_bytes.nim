import std/unittest
import surreal/private/cbor/[decoder, encoder, types, writer]
import surreal/private/types/[surrealTypes, surrealValue]

suite "CBOR:Decoder:Bytes":

    test "decode byte string #1":
        const data = @[
            encodeHeadByte(Bytes, 2.HeadArgument),
            0b0101_1010'u8,
            0b1010_0101'u8,
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealBytes)
        check(decoded.getBytes[0] == data[1])
        check(decoded.getBytes[1] == data[2])

    test "decode byte string #2":
        const length = 500
        var writer = newCborWriter()
        writer.encodeHead(Bytes, length)
        for i in 0..<length:
            let value = i mod 256
            writer.writeRawUInt(value.uint8)

        let decoded = decode(writer.getOutput())
        check(decoded.kind == SurrealBytes)
        for i in 0..<length:
            let value = i mod 256
            check(decoded.getBytes[i] == value.uint8)