import std/[unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue, null]

suite "CBOR:Encoder:Null":

    test "encode NULL":
        var writer = encode(%%% Null)
        check(writer.getOutput() == @[0b111_10110'u8])
        check(writer.getOutput() == @[0xf6'u8])
        writer = encode(surrealNull)
        check(writer.getOutput() == @[0b111_10110'u8])
        writer = encode(Null.toSurrealNull())
        check(writer.getOutput() == @[0b111_10110'u8])