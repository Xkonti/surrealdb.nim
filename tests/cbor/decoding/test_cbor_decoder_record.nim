import std/[unittest, tables]
import surreal/private/cbor/[decoder]
import surreal/private/types/[surrealValue, tableName]

suite "CBOR:Decoder:RecordID":

    test "decode a simple record":
        const data = @[
            0b110_01000'u8, # Tag for RecordID
            0b100_00010'u8, # Array with 2 elements
            0b011_00100'u8, 0x75, 0x73, 0x65, 0x72, # String "user" as table name
            0b011_00101'u8, 0x73, 0x6f, 0x6d, 0x65, 0x31 # String "some1" as value
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealRecordId)
        let record = decoded.getRecordId
        check(record.table == tb"user")
        check(record.id.kind == SurrealString)
        check(record.id.getString == "some1")

    test "decode a record with a complex id":
        const data = @[
            0b110_01000'u8, # Tag for RecordID
            0b100_00010'u8, # Array with 2 elements
            0b011_01011'u8, 0x6d, 0x65, 0x61, 0x73, 0x75, 0x72, 0x65, 0x6d, 0x65, 0x6e, 0x74, # String "measurement" as table name
            0b101_00010'u8, # Map with 2 elements
                0b011_01000'u8, 0x6c, 0x6f, 0x63, 0x61, 0x74, 0x69, 0x6f, 0x6e, # String "location" as key
                0b011_00101'u8, 0x61, 0x74, 0x74, 0x69, 0x63, # String "attic" as value
                0b011_01011'u8, 0x74, 0x65, 0x6d, 0x70, 0x65, 0x72, 0x61, 0x74, 0x75, 0x72, 0x65, # String "temperature" as key
                0b111_11011'u8, 0x40, 0x47, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9a # Float64 47.2 as value
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealRecordId)
        let record = decoded.getRecordId
        check(record.table == tb"measurement")
        check(record.id.kind == SurrealObject)
        let id = record.id.getTable
        check(id.len == 2)
        check(id.hasKey("location"))
        check(id["location"].kind == SurrealString)
        check(id["location"].getString == "attic")
        check(id.hasKey("temperature"))
        check(id["temperature"].kind == SurrealFloat)
        check(id["temperature"].toFloat64 == 47.2'f64)