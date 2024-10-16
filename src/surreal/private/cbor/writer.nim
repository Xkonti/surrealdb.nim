import std/[math]
import ../stew/[endians2, sequtils2]

proc writeRawUInt*(buffer: var seq[uint8], value: uint8) =
    ## Writes an integer to the CBOR data.
    buffer.add(value)

proc writeRawUInt*(buffer: var seq[uint8], value: uint16 | uint32 | uint64) =
    ## Writes an integer to the CBOR data using the appropriate number of bytes.
    ## The number of bytes is determined by the type of the value.
    buffer.write(value.toBytesBE)


type
    CborWriter* = ref object
        ## A writer for raw CBOR data (byte array).
        data: seq[uint8]
            ## The raw CBOR data.


proc newCborWriter*(): CborWriter =
    ## Creates a new CborWriter instance.
    return CborWriter(data: newSeq[uint8]())

proc len*(writer: CborWriter): int =
    ## Returns the length of the CBOR data in bytes.
    return writer.data.len

proc writeRawUInt*(buffer: CborWriter, value: uint8) =
    ## Writes an integer to the CBOR writer.
    writeRawUInt(buffer.data, value)

proc writeRawUInt*(buffer: CborWriter, value: uint16 | uint32 | uint64) =
    ## Writes an integer to the CBOR writer using the appropriate number of bytes.
    ## The number of bytes is determined by the type of the value.
    writeRawUInt(buffer.data, value)

proc writeFloat32*(buffer: CborWriter, value: float32) =
    ## Writes a float32 to the CBOR writer.
    # Nim encodes NaN in a way incompatible with CBOR
    if value.isNaN:
        buffer.data.write(@[0x7f'u8, 0xc0, 0x00, 0x00])
    else:
        writeRawUInt(buffer.data, cast[uint32](value))

proc writeFloat64*(buffer: CborWriter, value: float64) =
    ## Writes a float64 to the CBOR writer.
    # Nim encodes NaN in a way incompatible with CBOR
    if value.isNaN:
        buffer.data.write(@[0x7f'u8, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    else:
        writeRawUInt(buffer.data, cast[uint64](value))

proc writeBytes*(buffer: CborWriter, value: openArray[uint8]) =
    ## Writes a sequence of bytes to the CBOR writer.
    buffer.data.write(value)


proc getOutput*(buffer: CborWriter): seq[uint8] =
    ## Returns the output of the CBOR writer.
    return buffer.data