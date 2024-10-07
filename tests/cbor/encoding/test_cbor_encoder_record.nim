import std/[unittest, tables]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue, tableName]

suite "CBOR:Encoder:RecordID":

    test "Should encode an simple record":
        let value1 = newRecordId(tb"user", "some1").toSurrealRecordId
        let bytes = encode(value1).getOutput()
        check(bytes.len == 13)
        check(bytes == @[
            0b110_01000'u8, # Tag for RecordID
            0b100_00010'u8, # Array with 2 elements
            0b011_00100'u8, 0x75, 0x73, 0x65, 0x72, # String "user" as table name
            0b011_00101'u8, 0x73, 0x6f, 0x6d, 0x65, 0x31 # String "some1" as value
        ])

    test "Should encode a record with a complex id":
        let value1 = newRecordId(tb"measurement", %%% {
            "location": %%% "attic",
            "temperature": %%% 47.2'f64
        }).toSurrealRecordId
        let bytes = encode(value1).getOutput()
        check(bytes.len == 51)
        check(bytes == @[
            0b110_01000'u8, # Tag for RecordID
            0b100_00010'u8, # Array with 2 elements
            0b011_01011'u8, 0x6d, 0x65, 0x61, 0x73, 0x75, 0x72, 0x65, 0x6d, 0x65, 0x6e, 0x74, # String "measurement" as table name
            0b101_00010'u8, # Map with 2 elements
                0b011_01000'u8, 0x6c, 0x6f, 0x63, 0x61, 0x74, 0x69, 0x6f, 0x6e, # String "location" as key
                0b011_00101'u8, 0x61, 0x74, 0x74, 0x69, 0x63, # String "attic" as value
                0b011_01011'u8, 0x74, 0x65, 0x6d, 0x70, 0x65, 0x72, 0x61, 0x74, 0x75, 0x72, 0x65, # String "temperature" as key
                0b111_11011'u8, 0x40, 0x47, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9a # Float64 47.2 as value
        ])