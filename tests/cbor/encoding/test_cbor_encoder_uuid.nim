import std/[sequtils, unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Encoder:Uuid":

    test "should encode UUID value":
        let value = uuid"7839e750-4641-4cfa-8dea-449375145be3"
        let bytes = encode(%%% value).getOutput()
        check(bytes == @[
            0b110_11000'u8, 37, # Tag - 1 byte to encode the tag 37
            0b010_10000'u8, # 16 bytes
            120, 57, 231, 80, 70, 65, 76, 250, 141, 234, 68, 147, 117, 20, 91, 227
        ]) 
