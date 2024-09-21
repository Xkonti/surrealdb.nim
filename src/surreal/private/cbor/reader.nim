import std/[bitops, sequtils]
import types

type
    CborReader* = ref object
        ## A reader for raw CBOR data (byte array).
        data: seq[uint8]
            ## The raw CBOR data.
        pos: uint
            ## The current position to read from.

proc newCborReader*(data: openArray[uint8]): CborReader =
    ## Creates a new CborReader instance.
    return CborReader(data: data.toSeq, pos: 0)

proc readUInt8*(reader: CborReader): uint8 =
    ## Reads a single byte from the CBOR data as a uint8.
    result = reader.data[reader.pos]
    inc reader.pos

proc readUInt16*(reader: CborReader): uint16 =
    ## Rreads two bytes from the CBOR data as a uint16.
    result = bitand(
        (reader.data[reader.pos].uint16 shl 8),
        reader.data[reader.pos+1].uint16)
    inc reader.pos, 2

proc readUInt32*(reader: CborReader): uint32 =
    ## Reads four bytes from the CBOR data as a uint32.
    result = bitand(
        (reader.data[reader.pos].uint32 shl 24),
        (reader.data[reader.pos+1].uint32 shl 16),
        (reader.data[reader.pos+2].uint32 shl 8),
        reader.data[reader.pos+3].uint32)
    inc reader.pos, 4

proc readUInt64*(reader: CborReader): uint64 =
    ## Reads eight bytes from the CBOR data as a uint64.
    result = bitand(
        (reader.data[reader.pos].uint64 shl 56),
        (reader.data[reader.pos+1].uint64 shl 48),
        (reader.data[reader.pos+2].uint64 shl 40),
        (reader.data[reader.pos+3].uint64 shl 32),
        (reader.data[reader.pos+4].uint64 shl 24),
        (reader.data[reader.pos+5].uint64 shl 16),
        (reader.data[reader.pos+6].uint64 shl 8),
        reader.data[reader.pos+7].uint64)
    inc reader.pos, 8

proc readHead*(reader: CborReader): (HeadMajor, HeadArgument) =
    ## Reads the head of the CBOR data: the Major type and the argument (or additional bytes if necessary).
    let firstByte = reader.readUInt8()
    let majorType = (firstByte shr 5).HeadMajor
    let argument = firstByte.masked(0b00011111'u8).HeadArgument
    return (majorType, argument)

proc isBreak*(reader: CborReader, head: tuple[major: HeadMajor, argument: HeadArgument]): bool =
    ## Checks if the head suggests a break of indefinite sequence.
    return head.major == 7 and head.argument == 31

proc getFullArgument*(reader: CborReader, shortArgument: HeadArgument): uint64 =
    ## Gets the full argument from the short argument.
    result = case shortArgument
        of 0..23: shortArgument.uint64
        of 24: reader.readUInt8().uint64
        of 25: reader.readUInt16().uint64
        of 26: reader.readUInt32().uint64
        of 27: reader.readUInt64().uint64
        else: raise newException(ValueError, "Invalid argument: " & $shortArgument)