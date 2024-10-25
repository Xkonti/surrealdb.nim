import std/[unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Encoder:Future":

    test "should encode future":
        var bytes: seq[uint8] = @[
            0b110_01111'u8, # Future tag
            0b100_00010'u8, # Array with 2 elements
            0b000_00000'u8, # Positie 0
            0b000_00011'u8, # Positive 3
        ]

        let surrealValue = %%* [0, 3]
        let future = newFutureWrapper(surrealValue)
        let encoded = encode(future).getOutput()
        check(encoded == bytes)

