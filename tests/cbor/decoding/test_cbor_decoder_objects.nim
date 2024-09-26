import std/[unittest, tables]
import surreal/private/cbor/[constants, decoder, encoder, types]
import surreal/private/types/[surrealValue]

suite "CBOR:Decoder:Objects":

    test "decode an empty object":
        const data = @[
            encodeHeadByte(Map, 0.HeadArgument), # Map - 0 elements
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealObject)
        check(decoded.len == 0)
        check(decoded.getTable.len == 0)

    test "decode an object with a single element":
        const data = @[
            encodeHeadByte(Map, 1.HeadArgument), # Map - 1 element
            encodeHeadByte(String, Two), 0x69, 0x64, # String "id" as key
            encodeHeadByte(Bytes, Four), 0, 50, 100, 250 # 4 bytes as value
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealObject)
        check(decoded.len == 1)
        let table = decoded.getTable
        check(table.len == 1)
        check(table.hasKey("id"))
        let id = table["id"]
        check(id.kind == SurrealBytes)
        check(id.len == 4)
        check(id.getBytes == @[0'u8, 50, 100, 250])

    test "decode an object with multiple elements":
        const data = @[
            encodeHeadByte(Map, Three), # Map - 3 elements
            encodeHeadByte(String, Two), 0x69, 0x64, # String "id" as key
            encodeHeadByte(String, Ten), 0x70, 0x6f, 0x73, 0x74, 0x3a, 0x66, 0x69, 0x72, 0x73, 0x74, # Srting "post:first" as value
            encodeHeadByte(String, Six), 0x61, 0x75, 0x74, 0x68, 0x6f, 0x72, # String "author" as key
            encodeHeadByte(String, Thirteen), 0x75, 0x73, 0x65, 0x72, 0x3a, 0x31, 0x30, 0x32, 0x32, 0x33, 0x35, 0x34, 0x37, # String "user:10223547" as value
            encodeHeadByte(String, Five), 0x72, 0x6f, 0x6c, 0x65, 0x73, # String "roles" as key
            encodeHeadByte(Array, Two), # Array of 2 elements as value
                encodeHeadByte(String, Five), 0x61, 0x64, 0x6d, 0x69, 0x6e, # String "admin" as value 1
                encodeHeadByte(String, Five), 0x67, 0x75, 0x65, 0x73, 0x74, # String "guest" as value 2
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealObject)
        check(decoded.len == 3)
        let table = decoded.getTable
        check(table.len == 3)
        check(table.hasKey("id"))
        let id = table["id"]
        check id.kind == SurrealString
        check(id.getString == "post:first")
        check(table.hasKey("author"))
        let author = table["author"]
        check(author.kind == SurrealString)
        check(author.getString == "user:10223547")
        check(table.hasKey("roles"))
        let roles = table["roles"]
        check(roles.kind == SurrealArray)
        check(roles.len == 2)
        check(roles.getSeq[0].kind == SurrealString)
        check(roles.getSeq[0].getString == "admin")
        check(roles.getSeq[1].kind == SurrealString)
        check(roles.getSeq[1].getString == "guest")

    test "decode an empty indefinite object":
        const data = @[
            encodeHeadByte(Map, Indefinite), # Map - ? elements
            cborBreak, # Break
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealObject)
        check(decoded.len == 0)
        check(decoded.getTable.len == 0)

    test "decode a nested indefinite object":
        const data = @[
            encodeHeadByte(Map, Indefinite), # Map - ? elements
            encodeHeadByte(String, Three), 0x6f, 0x6e, 0x65, # String "one" as key
            encodeHeadByte(PosInt, OneByte), 200, # Positive integer 200
            encodeHeadByte(String, Three), 0x74, 0x77, 0x6f, # String "two" as key
            encodeHeadByte(Map, Indefinite), # Map - ? elements
                encodeHeadByte(String, Three), 0x32, 0x2d, 0x31, # String "2-1" as key
                encodeHeadByte(PosInt, OneByte), 64, # Positive integer 64
                encodeHeadByte(String, Three), 0x32, 0x2d, 0x32, # String "2-2" as key
                encodeHeadByte(Map, Indefinite), # Map - ? elements
                    cborBreak, # Break
                encodeHeadByte(String, Three), 0x32, 0x2d, 0x33, # String "2-3" as key
                encodeHeadByte(Map, Zero), # Map - 0 elements
                cborBreak, # Break
            encodeHeadByte(String, Five), 0x74, 0x68, 0x72, 0x65, 0x65, # String "three" as key
            encodeHeadByte(PosInt, Three), # Positive integer 3
            cborBreak, # Break
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealObject)
        check(decoded.len == 3)
        let table = decoded.getTable
        check(table.len == 3)

        check(table.hasKey("one"))
        let one = table["one"]
        check(one.kind == SurrealInteger)
        check(one.toInt32 == 200)

        check(table.hasKey("two"))
        let two = table["two"]
        check(two.kind == SurrealObject)
        check(two.len == 3)
        let twoTable = two.getTable
        check(twoTable.len == 3)

        check(twoTable.hasKey("2-1"))
        let two1Value = twoTable["2-1"]
        check(two1Value.kind == SurrealInteger)
        check(two1Value.toInt32 == 64)

        check(twoTable.hasKey("2-2"))
        let two2Value = twoTable["2-2"]
        check(two2Value.kind == SurrealObject)
        check(two2Value.len == 0)

        check(twoTable.hasKey("2-3"))
        let two3Value = twoTable["2-3"]
        check(two3Value.kind == SurrealObject)
        check(two3Value.len == 0)

        check(table.hasKey("three"))
        let three = table["three"]
        check(three.kind == SurrealInteger)
        check(three.toInt32 == 3)
