import std/[unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Encoder:Bool":

    test "encode true":
        const trueByte = 0b111_10101'u8

        var writer = encode(%%% true)
        check(writer.getOutput() == @[trueByte])
        writer = encode(surrealTrue)
        check(writer.getOutput() == @[trueByte])
        writer = encode(true.toSurrealBool())
        check(writer.getOutput() == @[trueByte])

        writer = encode(not %%% false)
        check(writer.getOutput() == @[trueByte])
        writer = encode(not surrealFalse)
        check(writer.getOutput() == @[trueByte])
        writer = encode(not false.toSurrealBool())
        check(writer.getOutput() == @[trueByte])

        writer = encode(%%% true)
        check(writer.getOutput() == @[0xf5'u8])

    test "encode false":
        const falseByte = 0b111_10100'u8
        var writer = encode(%%% false)
        check(writer.getOutput() == @[falseByte])
        writer = encode(surrealFalse)
        check(writer.getOutput() == @[falseByte])
        writer = encode(false.toSurrealBool())
        check(writer.getOutput() == @[falseByte])

        writer = encode(not %%% true)
        check(writer.getOutput() == @[falseByte])
        writer = encode(not surrealTrue)
        check(writer.getOutput() == @[falseByte])
        writer = encode(not true.toSurrealBool())
        check(writer.getOutput() == @[falseByte])

        writer = encode(%%% false)
        check(writer.getOutput() == @[0xf4'u8])