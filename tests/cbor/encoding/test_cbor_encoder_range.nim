import std/[unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[none, surrealValue]

suite "CBOR:Encoder:Range":

    test "should encode range with both bounds":
        var range = newSurrealRange(%%% 0, %%% 255, false, true)
        var bytes = encode(range).getOutput()
        check(bytes == @[0b110_11000'u8, 49, 0b100_00010, 0b110_11000, 51, 0b000_00000, 0b110_11000, 50, 0b000_11000, 255])

        range = newSurrealRange(%%% "Hi", %%% None, true, false)
        bytes = encode(range).getOutput()
        check(bytes == @[0b110_11000'u8, 49, 0b100_00010, 0b110_11000, 50, 0b011_00010, 0x48, 0x69, 0b110_11000, 51, 0b110_00110, 0b111_10110])

    test "should encode range with only start bound":
        var range = newSurrealStartOnlyRange(%%% 255, true)
        var bytes = encode(range).getOutput()
        check(bytes == @[0b110_11000'u8, 49, 0b100_00010, 0b110_11000, 50, 0b000_11000, 255, 0b110_00110, 0b111_10110])

    test "should encode range with only end bound":
        var range = newSurrealEndOnlyRange(%%% "Hi", false)
        var bytes = encode(range).getOutput()
        check(bytes == @[0b110_11000'u8, 49, 0b100_00010, 0b110_00110, 0b111_10110, 0b110_11000, 51, 0b011_00010, 0x48, 0x69])
