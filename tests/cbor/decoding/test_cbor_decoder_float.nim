import std/[math, unittest]
import surreal/private/cbor/[decoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Decoder:Integer":

    test "decode CBOR reference floats":
        # https://www.rfc-editor.org/rfc/rfc8949.html#name-examples-of-encoded-cbor-da

        var writer = newCborWriter()
        var decoded: SurrealValue

        # TODO: Implement encoding half-precision
        # decoded = decode(@[0xf9'u8, 0x00, 0x00])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat16 == 0.0'f16)

        # TODO: Implement encoding half-precision
        # decoded = decode(@[0xf9'u8, 0x80, 0x00])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat16 == -0.0'f16)

        # TODO: Implement encoding half-precision
        # decoded = decode(@[0xf9'u8, 0x3c, 0x00])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat16 == 1.0'f16)

        decoded = decode(@[0xfb'u8, 0x3f, 0xf1, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9a])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat64 == 1.1'f64)

        # TODO: Implement encoding half-precision
        # decoded = decode(@[0xf9'u8, 0x3e, 0x00])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat16 == 1.5'f16)

        # TODO: Implement encoding half-precision
        # decoded = decode(@[0xf9'u8, 0x7b, 0xff])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat16 == 65504.0'f16)

        # TODO: Implement encoding single-precision
        # decoded = decode(@[0xfa'u8, 0x47, 0xc3, 0x50, 0x00])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat32 == 100_000.0'f32)

        # TODO: Implement encoding single-precision
        # decoded = decode(@[0xfa'u8, 0x7f, 0x7f, 0xff, 0xff])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat32 == 3.4028234663852886e38'f32)

        decoded = decode(@[0xfb'u8, 0x7e, 0x37, 0xe4, 0x3c, 0x88, 0x00, 0x75, 0x9c])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat64 == 1.0e300'f64)

        # TODO: Implement encoding half-precision
        # decoded = decode(@[0xf9'u8, 0x00, 0x01])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat16 == 5.960464477539063e-8'f16)

        # TODO: Implement encoding half-precision
        # decoded = decode(@[0xf9'u8, 0x04, 0x00])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat16 == 0.00006103515625'f16)

        # TODO: Implement encoding half-precision
        # decoded = decode(@[0xf9'u8, 0xc4, 0x00])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat16 == -4.0'f16)

        decoded = decode(@[0xfb'u8, 0xc0, 0x10, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat64 == -4.1'f64)

        # TODO: Implement encoding half-precision
        # decoded = decode(@[0xf9'u8, 0x7c, 0x00])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat16 == Inf'f16)

        # TODO: Implement encoding half-precision)
        # decoded = decode(@[0xf9'u8, 0x7e, 0x00])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat16 == NaN'f16)

        # TODO: Implement encoding half-precision
        # decoded = decode(@[0xf9'u8, 0xfc, 0x00])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat16 == NegInf'f16)

        # TODO: Implement encoding single-precision
        # decoded = decode(@[0xfa'u8, 0x7f, 0x80])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat32 == Inf'f32)

        # TODO: Implement encoding single-precision)
        # decoded = decode(@[0xfa'u8, 0x7f, 0xc0])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat32 == NaN'f32)

        # TODO: Implement encoding single-precision
        # decoded = decode(@[0xfa'u8, 0xff, 0x00])
        # check(decoded.kind == SurrealFloat)
        # check(decoded.toFloat32 == NegInf'f32)

        decoded = decode(@[0xfb'u8, 0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat64 == Inf)

        decoded = decode(@[0xfb'u8, 0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat64.isNaN)

        decoded = decode(@[0xfb'u8, 0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        check(decoded.kind == SurrealFloat)
        check(decoded.toFloat64 == NegInf)