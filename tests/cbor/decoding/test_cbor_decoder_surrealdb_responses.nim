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

    test "Decode QUERY response #1":
        const bytes = @[
            162'u8, 98, 105, 100, 97, 52, 102, 114, 101, 115, 117, 108, 116, # obj with 2 el, "id" and "result"
            129, 163,                     102, 114, 101, 115, 117, 108, 116, # obj with 3 el, "result":...
            204, 130, # Tag 12 (datetime), array with 2 elements
            0b000_11010'u8, 0x67, 0x13, 0x30, 0xF4, # 1729310964 - seconds since epoch
            0b000_11010'u8, 0x1C, 0xDA, 0xC1, 0x5F, # 484098399 - nanoseconds
            102, 115, 116, 97, 116, 117, 115, # String "status"
            98, 79, 75, # String "OK"
            100, 116, 105, 109, 101, # String "time"
            105, 51, 55, 46, 51, 55, 49, 194, 181, 115 # String "37.371µs"
        ]
        let decoded = decode(bytes)
        check(decoded.kind == SurrealObject)
        check(decoded.len == 2)
        check(decoded["id"] == %%% "4")
        check(decoded["id"].getString == "4")
        let resultValue = decoded["result"]
        # [{⟨result⟩:2024-10-19T04:09:24Z,⟨status⟩:⟨OK⟩,⟨time⟩:⟨37.371µs⟩}]
        check(resultValue.kind == SurrealArray)
        check(resultValue.len == 1)
        let queryRes = resultValue.getSeq[0]
        check(queryRes.kind == SurrealObject)
        check(queryRes.len == 3)
        check(queryRes["result"] == newSurrealDatetime(1729310964'u64, 484098399))
        check(queryRes["status"] == %%% "OK")
        check(queryRes["time"] == %%% "37.371µs")

