import std/[math, unittest]
import surreal/private/cbor/[decoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Decoder:Future":

    test "decode simple future":
        var writer = newCborWriter()
        var decoded = decode(@[
            0b110_01111'u8, # Future tag
            0b100_00010'u8, # Array with 2 elements
            0b000_00000'u8, # Positie 0
            0b000_00011'u8, # Positive 3
        ])
        check(decoded.kind == SurrealFuture)
        let inner = decoded.unwrap()
        check(inner.kind == SurrealArray)
        check(inner.len == 2)
        check(inner.getSeq[0].kind == SurrealInteger)
        check(inner.getSeq[0].toInt32 == 0)
        check(inner.getSeq[1].kind == SurrealInteger)
        check(inner.getSeq[1].toInt32 == 3)
