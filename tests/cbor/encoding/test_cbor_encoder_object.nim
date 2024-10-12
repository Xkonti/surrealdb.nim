import std/[unittest, tables]
import surreal/private/cbor/[encoder, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Encoder:Object":

    test "Should encode an empty object":
        let value1 = newSurrealObject()
        let bytes = encode(value1).getOutput()
        check(bytes.len == 1)
        check(bytes == @[0b101_00000'u8]) # Object - 0 elements

    test "Should encode an object with a single element":
        let value1: SurrealObjectTable = {
            "Hello": %%% "World"
        }.toOrderedTable
        let bytes = encode(%%% value1).getOutput()
        check(bytes.len == 13)
        check(bytes == @[
            0b101_00001'u8, # Map with 1 element
            0b011_00101, 0x48, 0x65, 0x6c, 0x6c, 0x6f, # String "Hello" as key
            0b011_00101, 0x57, 0x6f, 0x72, 0x6c, 0x64 # String "World" as value
        ])

test "Should encode an object with multiple elements":
    let value1: SurrealObjectTable = {
        "id": %%% "user:admin",
        "username": %%% "Administrator",
        "employee_id": %%% 470_037_623,
        "roles": %%% @[%%% "admin", %%% "user"],
        "address": %%% {
            "street": %%% "212 E International Airport Road",
            "city": %%% "Anchorage",
            "state": %%% "AL",
            "zip": %%% 99518
        }
    }.toOrderedTable
    let bytes = encode(%%% value1).getOutput()
    const expectedBytes = @[
        0b101_00101'u8, # Map with 5 elements
        0b011_00010'u8, 0x69, 0x64, # String "id" as key
        0b011_01010'u8, 0x75, 0x73, 0x65, 0x72, 0x3a, 0x61, 0x64, 0x6d, 0x69, 0x6e, # String "user:admin" as value
        0b011_01000'u8, 0x75, 0x73, 0x65, 0x72, 0x6e, 0x61, 0x6d, 0x65, # String "username" as key
        0b011_01101'u8, 0x41, 0x64, 0x6d, 0x69, 0x6e, 0x69, 0x73, 0x74, 0x72, 0x61, 0x74, 0x6f, 0x72, # String "Administrator" as value
        0b011_01011'u8, 0x65, 0x6d, 0x70, 0x6c, 0x6f, 0x79, 0x65, 0x65, 0x5f, 0x69, 0x64, # String "employee_id" as key
        0b000_11010'u8, 0x1c, 0x04, 0x34, 0x77, # Positive integer 470_037_623 as value
        0b011_00101'u8, 0x72, 0x6f, 0x6c, 0x65, 0x73, # String "roles" as key
        0b100_00010'u8, # Array with 2 elements for value of roles
            0b011_00101'u8, 0x61, 0x64, 0x6d, 0x69, 0x6e, # String "admin" as value 1
            0b011_00100'u8, 0x75, 0x73, 0x65, 0x72, # String "user" as value 2
        0b011_00111'u8, 0x61, 0x64, 0x64, 0x72, 0x65, 0x73, 0x73, # String "address" as key
        0b101_00100'u8, # Map with 4 elements for value of address
            0b011_00110'u8, 0x73, 0x74, 0x72, 0x65, 0x65, 0x74, # String "street" as key
            0b011_11000'u8, 32, 0x32, 0x31, 0x32, 0x20, 0x45, 0x20, 0x49, 0x6e, 0x74, 0x65, 0x72, 0x6e, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x61, 0x6c, 0x20, 0x41, 0x69, 0x72, 0x70, 0x6f, 0x72, 0x74, 0x20, 0x52, 0x6f, 0x61, 0x64,
            0b011_00100'u8, 0x63, 0x69, 0x74, 0x79, # String "city" as key
            0b011_01001'u8, 0x41, 0x6e, 0x63, 0x68, 0x6f, 0x72, 0x61, 0x67, 0x65, # String "Anchorage" as value
            0b011_00101'u8, 0x73, 0x74, 0x61, 0x74, 0x65, # String "state" as key
            0b011_00010'u8, 0x41, 0x4c, # String "AL" as value
            0b011_00011'u8, 0x7a, 0x69, 0x70, # String "zip" as key
            0b000_11010'u8, 0x00, 0x01, 0x84, 0xBE # Positive integer 99518 as value
    ]
    check(bytes.len == expectedBytes.len)
    check(bytes == expectedBytes)