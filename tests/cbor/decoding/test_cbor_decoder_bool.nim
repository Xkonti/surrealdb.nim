import std/unittest
import surreal/private/cbor/[decoder]
import surreal/private/types/[surrealValue]

suite "CBOR:Decoder:Bool":
    const trueByte = 0b111_10101'u8
    const falseByte = 0b111_10100'u8

    test "decode true":
        let decoded = decode(@[trueByte])
        check(decoded.kind == SurrealBool)
        check(decoded.getBool == true)

    test "decode false":
        let decoded = decode(@[falseByte])
        check(decoded.kind == SurrealBool)
        check(decoded.getBool == false)