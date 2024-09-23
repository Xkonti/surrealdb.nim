import std/[strutils]
import writer, types
import ../types/[surrealValue, surrealTypes]

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


proc encode*(writer: CborWriter, value: SurrealValue) =
    ## Encodes the SurrealValue to the CBOR writer.
    case value.kind
    of SurrealInteger:
        let major = if value.isNegative: NegInt else: PosInt
        writer.encodeHead(major, value.toUInt64())
    of SurrealBytes:
        writer.encodeHead(Bytes, value.bytesVal.len.uint64)
        writer.writeBytes(value.bytesVal)
    of SurrealString:
        let bytes = value.toBytes()
        writer.encodeHead(String, bytes.len.uint64)
        writer.writeBytes(bytes)
    else:
        raise newException(ValueError, "Cannot encode a {0} value" % $value.kind)