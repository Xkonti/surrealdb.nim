import std/[unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue, none]

suite "CBOR:Encoder:None":

    test "encode NONE":
        var writer = encode(%%% None)
        check(writer.getOutput() == @[0b110_00110'u8, 0b111_10110'u8])
        writer = encode(surrealNone)
        check(writer.getOutput() == @[0b110_00110'u8, 0b111_10110'u8])
        writer = encode(None.toSurrealNone())
        check(writer.getOutput() == @[0b110_00110'u8, 0b111_10110'u8])