import std/unittest
import surreal/private/cbor/[decoder]
import surreal/private/types/[surrealValue]

suite "CBOR:Decoder:None":
    const undefinedByte = 0b111_10111'u8

    test "decode undefined as NONE":
        let decoded = decode(@[undefinedByte])
        check(decoded.kind == SurrealNone)
        check(decoded == surrealNone)

    test "decode NULL tagged as NONE as NONE":
        let decoded = decode(@[0b110_00110'u8, 0b111_10110'u8])
        check(decoded.kind == SurrealNone)
        check(decoded == surrealNone)