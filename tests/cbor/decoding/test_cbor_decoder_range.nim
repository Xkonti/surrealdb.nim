import std/[unittest]
import surreal/private/cbor/[decoder]
import surreal/private/types/[none, surrealValue]

suite "CBOR:Decoder:Range":

    test "can decode range with both bounds":
        var decoded = decode(@[0b110_11000'u8, 49, 0b100_00010'u8, 0b110_11000, 51, 0b000_00000, 0b110_11000, 50, 0b000_11000, 255])
        check(decoded.kind == SurrealRange)
        check(decoded.getRangeStart() == %%% 0)
        check(decoded.getRangeEnd() == %%% 255)
        check(decoded.getStartBound() == Exclusive)
        check(decoded.getEndBound() == Inclusive)
        check(decoded == newSurrealRange(%%% 0, %%% 255, false, true))

        decoded = decode(@[0b110_11000'u8, 49, 0b100_00010'u8, 0b110_11000, 50, 0b011_00010, 0x48, 0x69, 0b110_11000, 51, 0b110_00110, 0b111_10110])
        check(decoded.kind == SurrealRange)
        check(decoded.getRangeStart() == %%% "Hi")
        check(decoded.getRangeEnd() == %%% None)
        check(decoded.getStartBound() == Inclusive)
        check(decoded.getEndBound() == Exclusive)
        check(decoded == newSurrealRange(%%% "Hi", %%% None, true, false))

    test "can decode range with only start bound":
        var decoded = decode(@[0b110_11000'u8, 49, 0b100_00010'u8, 0b110_11000, 51, 0b000_00000, 0b111_10110])
        check(decoded.kind == SurrealRange)
        check(decoded.getRangeStart() == %%% 0)
        check(decoded.getRangeEnd() == surrealNone)
        check(decoded.getStartBound() == Exclusive)
        check(decoded.getEndBound() == Unbounded)
        check(decoded == newSurrealStartOnlyRange(%%% 0, false))

    test "can decode range with only end bound":
        var decoded = decode(@[0b110_11000'u8, 49, 0b100_00010'u8, 0b111_10110, 0b110_11000, 51, 0b110_00110, 0b111_10110])
        check(decoded.kind == SurrealRange)
        check(decoded.getRangeStart() == surrealNone)
        check(decoded.getRangeEnd() == surrealNone)
        check(decoded.getStartBound() == Unbounded)
        check(decoded.getEndBound() == Exclusive)
        check(decoded == newSurrealEndOnlyRange(%%% None, false))
