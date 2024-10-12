import std/unittest
import surreal/private/cbor/[decoder, types]
import surreal/private/types/[surrealValue, tableName]

suite "CBOR:Decoder:TableName":

    test "decode table name":
        const tableName = tb"approved_by"
        const bytes = @[0b110_00111'u8, 0b011_01011, 0x61, 0x70, 0x70, 0x72, 0x6f, 0x76, 0x65, 0x64, 0x5f, 0x62, 0x79]
        let decoded = decode(bytes)
        check(decoded.kind == SurrealTable)
        check(decoded.getTableName == tableName)