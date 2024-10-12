## Tests decoding real-life SurrealDB responses

import std/[unittest]
import surreal/private/cbor/[decoder]
import surreal/private/types/[surrealValue, none]

suite "CBOR:Decoder:SurrealDB":

    test "Decode USE response":
        const bytes = @[162'u8, 98, 105, 100, 97, 49, 102, 114, 101, 115, 117, 108, 116, 198, 246]
        let decoded = decode(bytes)
        check(decoded.kind == SurrealObject)
        check(decoded.len == 2)
        check(decoded["id"] == %%% "1")
        check(decoded["id"].getString == "1")
        check(decoded["result"] == %%% None)