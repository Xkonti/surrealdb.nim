import std/[unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[none, surrealValue]

suite "CBOR:Encoder:Range":

    test "should encode range":
        var range = newSurrealRange(%%% 0, %%% 255, false, true)
        var bytes = encode(range).getOutput()
        check(bytes == @[0b110_11000'u8, 49, 0b100_00010'u8, 0b110_11000, 51, 0b000_00000, 0b110_11000, 50, 0b000_11000, 255])

        range = newSurrealRange(%%% "Hi", %%% None, true, false)
        bytes = encode(range).getOutput()
        check(bytes == @[0b110_11000'u8, 49, 0b100_00010'u8, 0b110_11000, 50, 0b011_00010, 0x48, 0x69, 0b110_11000, 51, 0b110_00110, 0b111_10110])
