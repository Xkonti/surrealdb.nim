import std/[math, unittest]
import surreal/private/cbor/[decoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Decoder:Float":

    test "decode CBOR reference floats":
        # https://www.rfc-editor.org/rfc/rfc8949.html#name-examples-of-encoded-cbor-da

        var writer = newCborWriter()
        var decoded: SurrealValue

        decoded = decode(@[0xf9'u8, 0x00, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat32 == 0.0'f32)

        decoded = decode(@[0xf9'u8, 0x80, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat32 == -0.0'f32)

        decoded = decode(@[0xf9'u8, 0x3c, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat32 == 1.0'f32)

        decoded = decode(@[0xfb'u8, 0x3f, 0xf1, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9a])
        check(decoded.kind == SurrealFloat)
        check(decoded.getFloat64 == 1.1'f64)

        decoded = decode(@[0xf9'u8, 0x3e, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat32 == 1.5'f32)

        decoded = decode(@[0xf9'u8, 0x7b, 0xff])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat32 == 65504.0'f32)

        decoded = decode(@[0xfa'u8, 0x47, 0xc3, 0x50, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.getFloat32 == 100_000.0'f32)

        decoded = decode(@[0xfa'u8, 0x7f, 0x7f, 0xff, 0xff])
        check(decoded.kind == SurrealFloat)
        check(decoded.getFloat32 == 3.4028234663852886e38'f32)

        decoded = decode(@[0xfb'u8, 0x7e, 0x37, 0xe4, 0x3c, 0x88, 0x00, 0x75, 0x9c])
        check(decoded.kind == SurrealFloat)
        check(decoded.getFloat64 == 1.0e300'f64)

        decoded = decode(@[0xf9'u8, 0x00, 0x01])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat32 == 5.960464477539063e-8'f32)

        decoded = decode(@[0xf9'u8, 0x04, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat32 == 0.00006103515625'f32)

        decoded = decode(@[0xf9'u8, 0xc4, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat32 == -4.0'f32)

        decoded = decode(@[0xfb'u8, 0xc0, 0x10, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66])
        check(decoded.kind == SurrealFloat)
        check(decoded.getFloat64 == -4.1'f64)

        decoded = decode(@[0xf9'u8, 0x7c, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat32 == Inf.float32)

        decoded = decode(@[0xf9'u8, 0x7e, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat32.isNaN)

        decoded = decode(@[0xf9'u8, 0xfc, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat32 == NegInf.float32)

        decoded = decode(@[0xfa'u8, 0x7f, 0x80, 0x00, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.getFloat32 == Inf.float32)

        decoded = decode(@[0xfa'u8, 0x7f, 0xc0, 0x00, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.getFloat32.isNaN)

        decoded = decode(@[0xfa'u8, 0xff, 0x80, 0x00, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.getFloat32 == NegInf.float32)

        decoded = decode(@[0xfb'u8, 0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.getFloat64 == Inf)

        decoded = decode(@[0xfb'u8, 0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.getFloat64.isNaN)

        decoded = decode(@[0xfb'u8, 0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.getFloat64 == NegInf)
