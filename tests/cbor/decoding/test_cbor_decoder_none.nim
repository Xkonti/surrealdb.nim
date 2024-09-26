import std/unittest
import surreal/private/cbor/[decoder]
import surreal/private/types/[surrealValue]

suite "CBOR:Decoder:None":
    const undefinedByte = 0b111_10111'u8

    test "decode undefined as none":
        let decoded = decode(@[undefinedByte])
        check(decoded.kind == SurrealNone)
        check(decoded == surrealNone)