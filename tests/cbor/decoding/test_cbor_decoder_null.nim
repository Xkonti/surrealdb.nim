import std/unittest
import surreal/private/cbor/[decoder]
import surreal/private/types/[surrealValue]

suite "CBOR:Decoder:Null":
    const nullByte = 0b111_10110'u8

    test "decode null":
        let decoded = decode(@[nullByte])
        check(decoded.kind == SurrealNull)
        check(decoded == surrealNull)