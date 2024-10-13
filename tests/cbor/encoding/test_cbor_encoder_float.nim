import std/[unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Encoder:Float":

    test "Encode CBOR reference floats":
        # https://www.rfc-editor.org/rfc/rfc8949.html#name-examples-of-encoded-cbor-da

        var bytes: seq[uint8] = @[]

        # TODO: Implement encoding half-precision
        # bytes = encode(%%% 0.0'f16).getOutput()
        # check(bytes == @[0xf9'u8, 0x00, 0x00])

        # TODO: Implement encoding half-precision
        # bytes = encode(%%% -0.0'f16).getOutput()
        # check(bytes == @[0xf9'u8, 0x80, 0x00])

        # TODO: Implement encoding half-precision
        # bytes = encode(%%% 1.0'f16).getOutput()
        # check(bytes == @[0xf9'u8, 0x3c, 0x00])

        bytes = encode(%%% 1.1'f64).getOutput()
        check(bytes.len == 9)
        check(bytes == @[0xfb'u8, 0x3f, 0xf1, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9a])

        # TODO: Implement encoding half-precision
        # bytes = encode(%%% 1.5'f16).getOutput()
        # check(bytes == @[0xf9'u8, 0x3e, 0x00])

        # TODO: Implement encoding half-precision
        # bytes = encode(%%% 65504.0'f16).getOutput()
        # check(bytes == @[0xf9'u8, 0x7b, 0xff])

        bytes = encode(%%% 100_000.0'f32).getOutput()
        check(bytes == @[0xfa'u8, 0x47, 0xc3, 0x50, 0x00])

        bytes = encode(%%% 3.4028234663852886e38'f32).getOutput()
        check(bytes == @[0xfa'u8, 0x7f, 0x7f, 0xff, 0xff])

        bytes = encode(%%% 1.0e300'f64).getOutput()
        check(bytes == @[0xfb'u8, 0x7e, 0x37, 0xe4, 0x3c, 0x88, 0x00, 0x75, 0x9c])

        # TODO: Implement encoding half-precision
        # bytes = encode(%%% 5.960464477539063e-8'f16).getOutput()
        # check(bytes == @[0xf9'u8, 0x00, 0x01])

        # TODO: Implement encoding half-precision
        # bytes = encode(%%% 0.00006103515625'f16).getOutput()
        # check(bytes == @[0xf9'u8, 0x04, 0x00])

        # TODO: Implement encoding half-precision
        # bytes = encode(%%% -4.0'f16).getOutput()
        # check(bytes == @[0xf9'u8, 0xc4, 0x00])

        bytes = encode(%%% -4.1'f64).getOutput()
        check(bytes == @[0xfb'u8, 0xc0, 0x10, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66])

        # TODO: Implement encoding half-precision
        # bytes = encode(%%% Inf'f16).getOutput()
        # check(bytes == @[0xf9'u8, 0x7c, 0x00])

        # TODO: Implement encoding half-precision
        # bytes = encode(%%% NaN'f16).getOutput()
        # # check(bytes == @[0xf9'u8, 0x7e, 0x00])

        # TODO: Implement encoding half-precision
        # bytes = encode(%%% NegInf'f16).getOutput()
        # # check(bytes == @[0xf9'u8, 0xfc, 0x00])

        bytes = encode(%%% Inf.float32).getOutput()
        check(bytes == @[0xfa'u8, 0x7f, 0x80, 0x00, 0x00])

        bytes = encode(%%% NaN.float32).getOutput()
        check(bytes == @[0xfa'u8, 0x7f, 0xc0, 0x00, 0x00])

        bytes = encode(%%% NegInf.float32).getOutput()
        check(bytes == @[0xfa'u8, 0xff, 0x80, 0x00, 0x00])

        bytes = encode(%%% Inf).getOutput()
        check(bytes == @[0xfb'u8, 0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])

        bytes = encode(%%% NaN).getOutput()
        check(bytes == @[0xfb'u8, 0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])

        bytes = encode(%%% NegInf).getOutput()
        check(bytes == @[0xfb'u8, 0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
