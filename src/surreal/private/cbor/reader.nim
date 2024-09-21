import std/[bitops, endians, sequtils]
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
    bigEndian16(result.addr, reader.data[reader.pos].addr)
    inc reader.pos, 2

proc readUInt32*(reader: CborReader): uint32 =
    ## Reads four bytes from the CBOR data as a uint32.
    bigEndian32(result.addr, reader.data[reader.pos].addr)
    inc reader.pos, 4

proc readUInt64*(reader: CborReader): uint64 =
    ## Reads eight bytes from the CBOR data as a uint64.
    bigEndian64(result.addr, reader.data[reader.pos].addr)
    inc reader.pos, 8

proc readBytes*(reader: CborReader, numberOfBytes: uint64): seq[uint8] =
    ## Reads the specified number of bytes from the CBOR data into a new sequence.
    result = reader.data[reader.pos..<reader.pos+numberOfBytes].toSeq

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