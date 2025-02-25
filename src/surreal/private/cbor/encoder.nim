import std/[strutils, tables, times]
import constants, writer, types
import ../types/[surrealValue, duration]

proc encodeHeadByte*(major: HeadMajor, argument: HeadArgument): uint8 =
    ## Encodes the first byte of the head of the CBOR data.
    return (major.uint8 shl 5) or argument.uint8

proc encodeHeadByte*(writer: CborWriter, major: HeadMajor, argument: HeadArgument) =
    ## Encodes the first byte of the head of the CBOR data.
    writer.writeRawUInt(encodeHeadByte(major, argument))

proc encodeHead*(writer: CborWriter, major: HeadMajor, length: uint64)=
    ## Encodes the head of the CBOR data with the specified length of content.
    let head: uint8 = (major.uint8 shl 5)
    if length < 24:
        writer.writeRawUInt(head.uint8 or length.uint8)
    elif length <= uint8.high:
        writer.writeBytes([head.uint8 or 24, length.uint8])
    elif length <= uint16.high:
        writer.writeRawUInt(head.uint8 or 25)
        writer.writeRawUInt(length.uint16)
    elif length <= uint32.high:
        writer.writeRawUInt(head.uint8 or 26)
        writer.writeRawUInt(length.uint32)
    else:
        writer.writeRawUInt(head.uint8 or 27)
        writer.writeRawUInt(length.uint64)

proc encodeBool(writer: CborWriter, value: bool) =
    ## Encodes a bool to the CBOR writer.
    if value:
        writer.writeRawUInt(0b111_10101'u8)
    else:
        writer.writeRawUInt(0b111_10100'u8)

proc encodePosInteger(writer: CborWriter, value: uint | uint8 | uint16 | uint32 | uint64) =
    ## Encodes a positive integer to the CBOR writer.
    encodeHead(writer, PosInt, value.uint64)

proc encodeNegInteger(writer: CborWriter, value: uint | uint8 | uint16  | uint32  | uint64) =
    ## Encodes a negative integer to the CBOR writer.
    encodeHead(writer, NegInt, value.uint64)

proc encodeString(writer: CborWriter, value: string) =
    ## Encodes a string to the CBOR writer.
    let bytes = cast[seq[uint8]](value)
    writer.encodeHead(String, bytes.len.uint64)
    writer.writeBytes(bytes)


proc encode*(writer: CborWriter, value: SurrealValue) =
    ## Encodes the SurrealValue to the CBOR writer.
    case value.kind
    of SurrealArray:
        writer.encodeHead(Array, value.len.uint64)
        for item in value.getSeq:
            encode(writer, item)

    of SurrealBool:
        writer.encodeBool(value.getBool)

    of SurrealBytes:
        writer.encodeHead(Bytes, value.getBytes.len.uint64)
        writer.writeBytes(value.getBytes)

    of SurrealDatetime:
        # Dates are always encoded in the compact style
        const initialBytes = [
            0b110_01100'u8, # Tag for compact datetime
            0b100_00010'u8, # Array with 2 elements
        ]
        writer.writeBytes(initialBytes)
        let time = value.getTime
        writer.encodePosInteger(time.toUnix.uint64)
        writer.encodePosInteger(time.nanosecond.uint64)

    of SurrealDuration:
        # Duration is always encoded in the compact style (tag 14)
        const initialBytes = [
            0b110_01110'u8, # Tag for compact duration
            0b100_00010'u8, # Array with 2 elements
        ]
        writer.writeBytes(initialBytes)
        let duration = value.getDuration
        writer.encodePosInteger(duration.seconds)
        writer.encodePosInteger(duration.nanoseconds)

    of SurrealFloat:
        # TODO: Add support for encoding half and single precision floats
        # For now let's encode everything as float64
        case value.floatKind
        of Float32:
            writer.encodeHeadByte(Simple, FourBytes)
            writer.writeFloat32(value.getFloat32)
        of Float64:
            writer.encodeHeadByte(Simple, EightBytes)
            writer.writeFloat64(value.getFloat64)

    of SurrealFuture:
        # Future tag simply wraps the inner value
        writer.writeBytes([0b110_01111'u8])
        encode(writer, value.unwrap())

    of SurrealInteger:
        if value.isPositive:
            writer.encodePosInteger(value.getRawInt())
        else:
            writer.encodeNegInteger(value.getRawInt())

    of SurrealNone:
        writer.writeBytes(noneBytes)

    of SurrealNull:
        writer.writeRawUInt(nullByte)

    of SurrealObject:
        writer.encodeHead(Map, value.len.uint64)
        for pair in value.getTable.pairs:
            writer.encodeString(pair[0])
            encode(writer, pair[1])

    of SurrealRange:
        const initialBytes = [
            0b110_11000'u8, # Tag for range with 1 byte to encode the tag
            TagRange.uint8,
            0b100_00010'u8, # Array with 2 elements
        ]
        writer.writeBytes(initialBytes)
        # Start value
        case value.getStartBound:
        of Unbounded:
            writer.writeRawUInt(nullByte)
        of Inclusive:
            writer.writeBytes([0b110_11000'u8, TagBoundIncluded.uint8])
            writer.encode(value.getRangeStart())
        of Exclusive:
            writer.writeBytes([0b110_11000'u8, TagBoundExcluded.uint8])
            writer.encode(value.getRangeStart())
        # End value
        case value.getEndBound:
        of Unbounded:
            writer.writeRawUInt(nullByte)
        of Inclusive:
            writer.writeBytes([0b110_11000'u8, TagBoundIncluded.uint8])
            writer.encode(value.getRangeEnd())
        of Exclusive:
            writer.writeBytes([0b110_11000'u8, TagBoundExcluded.uint8])
            writer.encode(value.getRangeEnd())

    of SurrealRecordId:
        const initialBytes = [
            0b110_01000'u8, # Tag for RecordID
            0b100_00010'u8, # Array with 2 elements
        ]
        writer.writeBytes(initialBytes)
        # Table name (string)
        let record = value.getRecordId
        let bytes = cast[seq[uint8]](record.table.string)
        writer.encodeHead(String, bytes.len.uint64)
        writer.writeBytes(bytes)
        # Record ID data
        encode(writer, record.id)

    of SurrealString:
        let bytes = value.toBytes()
        writer.encodeHead(String, bytes.len.uint64)
        writer.writeBytes(bytes)

    of SurrealTable:
        writer.encodeHead(Tag, TagTableName.uint64)
        let bytes = value.toBytes()
        writer.encodeHead(String, bytes.len.uint64)
        writer.writeBytes(bytes)

    of SurrealUuid:
        let bytes = value.getUuid
        writer.encodeHead(Tag, TagUuidBinary.uint64)
        writer.encodeHeadByte(Bytes, Sixteen)
        writer.writeBytes(bytes)

    else:
        raise newException(ValueError, "Cannot encode a $1 value" % $value.kind)

proc encode*(value: SurrealValue): CborWriter =
    ## Encodes the SurrealValue to the CBOR writer.
    let writer = newCborWriter()
    encode(writer, value)
    return writer
