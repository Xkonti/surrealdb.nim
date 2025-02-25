import std/[sequtils, unittest]
import surreal/private/types/[surrealValue]

suite "SurrealValue:Uuid":

    test "Can be created from a string":
        const value1 = "e6d6a0a9-e2d7-4f9c-b8a8-d0b5e3d1f8d8"
        var surrealValue = value1.toSurrealUuid()
        check(surrealValue.kind == SurrealUuid)
        check(surrealValue.getUuid == @[230'u8, 214, 160, 169, 226, 215, 79, 156, 184, 168, 208, 181, 227, 209, 248, 216])
        const value2 = "BA8c31E1-DD3f-4D2B-A3E3-F0E5B4C2a0B0"
        surrealValue = value2.toSurrealUuid()
        check(surrealValue.kind == SurrealUuid)
        check(surrealValue.getUuid == @[186'u8, 140, 49, 225, 221, 63, 77, 43, 163, 227, 240, 229, 180, 194, 160, 176])
        const value3 = "e6d6a0a9e2d74f9cb8a8d0b5e3d1f8d8"
        surrealValue = value3.toSurrealUuid()
        check(surrealValue.kind == SurrealUuid)
        check(surrealValue.getUuid == @[230'u8, 214, 160, 169, 226, 215, 79, 156, 184, 168, 208, 181, 227, 209, 248, 216])
        const value4 = "BA8C31E1DD3F4D2BA3E3F0E5B4C2A0B0"
        surrealValue = value4.toSurrealUuid()
        check(surrealValue.kind == SurrealUuid)
        check(surrealValue.getUuid == @[186'u8, 140, 49, 225, 221, 63, 77, 43, 163, 227, 240, 229, 180, 194, 160, 176])
        const value5 = "e6D6a0A9-e2D74f9c-b8A8-d0b5e3d1f8d8"
        surrealValue = value5.toSurrealUuid()
        check(surrealValue.kind == SurrealUuid)
        check(surrealValue.getUuid == @[230'u8, 214, 160, 169, 226, 215, 79, 156, 184, 168, 208, 181, 227, 209, 248, 216])
        const value6 = "BA8c31E1DD3f-4D2BA3E3F0E5b4C2a0B0"
        surrealValue = value6.toSurrealUuid()
        check(surrealValue.kind == SurrealUuid)
        check(surrealValue.getUuid == @[186'u8, 140, 49, 225, 221, 63, 77, 43, 163, 227, 240, 229, 180, 194, 160, 176])

        surrealValue = uuid"00000000-0000-0000-0000-000000000000"
        check(surrealValue.kind == SurrealUuid)
        check(surrealValue == zeroUuid)
        check(surrealValue.getUuid == zeroUuid.getUuid)
        
        surrealValue = uuid"ffffffff-ffff-ffff-ffff-ffffffffffff"
        check(surrealValue.kind == SurrealUuid)
        check(surrealValue == maxUuid)
        check(surrealValue.getUuid == maxUuid.getUuid)

    test "Can be created from a sequence of bytes":
        const value1: seq[uint8] = @[230'u8, 214, 160, 169, 226, 215, 79, 156, 184, 168, 208, 181, 227, 209, 248, 216]
        var surrealValue = value1.toSurrealUuid()
        check(surrealValue.kind == SurrealUuid)
        check(surrealValue.getUuid == value1)
        
        const value2: seq[uint8] = @[43'u8, 150, 136, 31, 97, 201, 2, 48, 32, 32, 250, 190, 113, 221, 16, 88]
        surrealValue = value2.toSurrealUuid()
        check(surrealValue.kind == SurrealUuid)
        check(surrealValue.getUuid == value2.toSeq)

    test "Can be created from an array of bytes":
        const value1: array[16, uint8] = [230'u8, 214, 160, 169, 226, 215, 79, 156, 184, 168, 208, 181, 227, 209, 248, 216]
        var surrealValue = value1.toSurrealUuid()
        check(surrealValue.kind == SurrealUuid)
        check(surrealValue.getUuid == value1)

        const value2: array[16, uint8] = [43'u8, 150, 136, 31, 97, 201, 2, 48, 32, 32, 250, 190, 113, 221, 16, 88]
        surrealValue = value2.toSurrealUuid()
        check(surrealValue.kind == SurrealUuid)
        check(surrealValue.getUuid == value2.toSeq)

    test "Can compare UUIDs":
        let uuid1 = uuid"00000000-0000-0000-0000-000000000000"
        let uuid2 = uuid"00000000-0000-0000-0000-000000000000"
        check(uuid1 == uuid2)

        check(zeroUuid == zeroUuid)
        check(maxUuid == maxUuid)
        check(zeroUuid != maxUuid)
        check(maxUuid != zeroUuid)

        let uuid3 = uuid"abcdef01-2345-6789-abcd-ef0123456789"
        let uuid4 = uuid"abcdef01-2345-6789-abcd-ef0123456789"
        check(uuid3 == uuid4)

    test "Can print out UUIDs":
        let uuid1 = uuid"00000000-0000-0000-0000-000000000000"
        check($uuid1 == "<uuid> \"00000000-0000-0000-0000-000000000000\"")

        let uuid2 = uuid"ABCDEF01-2345-6789-ABCD-EF0123456789"
        check($uuid2 == "<uuid> \"ABCDEF01-2345-6789-ABCD-EF0123456789\"")
