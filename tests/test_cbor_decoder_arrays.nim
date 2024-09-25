import std/unittest
import surreal/private/cbor/[constants, decoder, encoder, types]
import surreal/private/types/[surrealValue]

suite "CBOR:Decoder:Arrays":

    test "decode finite array #1":
        const data = @[
            encodeHeadByte(Array, 2.HeadArgument), # Array of 2 elements
            encodeHeadByte(PosInt, 1.HeadArgument), # Positive integer 1
            encodeHeadByte(NegInt, OneByte), # Negative integer represended by 1 byte
            0b1111_1111'u8, # Integer -256
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealArray)
        check(decoded.len == 2)
        check(decoded.getSeq[0].kind == SurrealInteger)
        check(decoded.getSeq[0].isNegative == false)
        check(decoded.getSeq[0].toUInt64 == 1)
        check(decoded.getSeq[1].kind == SurrealInteger)
        check(decoded.getSeq[1].isNegative == true)
        check(decoded.getSeq[1].toInt16 == -256'i16)

    test "decode indefinite array #1":
        const data = @[
            0b100_11111'u8, # Array of ? elements
            0b000_00011'u8, # Positive integer 3
            0b001_11000'u8, # Negative integer represended by 1 byte
            0b1111_1111'u8, # Integer -256
            0b000_00100'u8, # Positive integer 4
            cborBreak, # Break
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealArray)
        check(decoded.len == 3)
        check(decoded.getSeq[0].kind == SurrealInteger)
        check(decoded.getSeq[0].isNegative == false)
        check(decoded.getSeq[0].toUInt64 == 3)
        check(decoded.getSeq[1].kind == SurrealInteger)
        check(decoded.getSeq[1].isNegative == true)
        check(decoded.getSeq[1].toInt16 == -256'i16) # Should be really -256
        check(decoded.getSeq[2].kind == SurrealInteger)
        check(decoded.getSeq[2].isNegative == false)
        check(decoded.getSeq[2].toUInt64 == 4)

    test "decode nested indefinite array #1":
        const data = @[
            encodeHeadByte(Array, Indefinite), # Array of ? elements
            encodeHeadByte(PosInt, 3.HeadArgument), # Positive integer 3
            encodeHeadByte(Array, Indefinite), # Array of ? elements
            encodeHeadByte(PosInt, 3.HeadArgument), # Positive integer 3
            encodeHeadByte(PosInt, 3.HeadArgument), # Positive integer 3
            encodeHeadByte(PosInt, 3.HeadArgument), # Positive integer 3
            cborBreak, # Break
            encodeHeadByte(PosInt, 4.HeadArgument), # Positive integer 4
            cborBreak, # Break
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealArray)
        check(decoded.len == 3)
        check(decoded.getSeq[0].kind == SurrealInteger)
        check(decoded.getSeq[0].isNegative == false)
        check(decoded.getSeq[0].toUInt64 == 3)
        check(decoded.getSeq[1].kind == SurrealArray)
        check(decoded.getSeq[1].len == 3)
        check(decoded.getSeq[1].getSeq[0].kind == SurrealInteger)
        check(decoded.getSeq[1].getSeq[0].isNegative == false)
        check(decoded.getSeq[1].getSeq[0].toUInt64 == 3)
        check(decoded.getSeq[1].getSeq[1].kind == SurrealInteger)
        check(decoded.getSeq[1].getSeq[1].isNegative == false)
        check(decoded.getSeq[1].getSeq[1].toUInt64 == 3)
        check(decoded.getSeq[1].getSeq[2].kind == SurrealInteger)
        check(decoded.getSeq[1].getSeq[2].isNegative == false)
        check(decoded.getSeq[1].getSeq[2].toUInt64 == 3)
        check(decoded.getSeq[2].kind == SurrealInteger)
        check(decoded.getSeq[2].isNegative == false)
        check(decoded.getSeq[2].toUInt64 == 4)