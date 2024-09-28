import std/[unittest]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue, tableName]

suite "CBOR:Encoder:TableName":

    test "encode simple table name":
        const tableName = tb"located_at"
        let bytes = encode(%%% tableName).getOutput()
        check(bytes == @[0b110_00111'u8, 0b011_01010, 0x6c, 0x6f, 0x63, 0x61, 0x74, 0x65, 0x64, 0x5f, 0x61, 0x74])