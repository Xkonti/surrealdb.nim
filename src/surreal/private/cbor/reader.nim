import std/[bitops, endians, sequtils, strbasics]
import types

type
    CborReader* = ref object
        ## A reader for raw CBOR data (byte array).
        data: seq[uint8]
            ## The raw CBOR data.
        pos: uint64
            ## The current position to read from.

proc newCborReader*(data: openArray[uint8]): CborReader =
    ## Creates a new CborReader instance.
    return CborReader(data: data.toSeq, pos: 0)

proc getBytesLeft*(reader: CborReader): uint64 =
    ## Returns the number of bytes left in the CBOR data.
    return reader.data.len.uint64 - reader.pos

proc isEnd*(reader: CborReader): bool =
    ## Checks if the reader has reached the end of the CBOR data.
    return reader.pos >= reader.data.len.uint64

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

proc readFloat16*(reader: CborReader): float32 =
    ## Reads two bytes from the CBOR data representing a half-precision float (f16).
    ## As Nim doesn't support half-precision floats, the float16 is converted to float32.
    let half: uint16 = uint16(reader.data[reader.pos]) shl 8 or uint16(reader.data[reader.pos+1])
    inc reader.pos, 2
    let sign = (half shr 15) and 0x1'u16
    let exp = (half shr 10) and 0x1f'u16
    let mant = half and 0x3ff'u16
    var f: uint32
    if exp == 0:
        if mant == 0:
            # Zero
            f = uint32(sign) shl 31
        else:
            # Subnormal numbers
            var mantissa = mant
            var exponent = int16(exp)
            while (mantissa and 0x400'u16) == 0:
                mantissa = mantissa shl 1
                exponent -= 1
            exponent += 1
            mantissa = mantissa and 0x3ff'u16
            var float_exp = uint32(exponent + (127 - 15))
            var float_mant = uint32(mantissa) shl 13
            f = (uint32(sign) shl 31) or (float_exp shl 23) or float_mant
    elif exp == 31:
        if mant == 0:
            # Infinity
            f = (uint32(sign) shl 31) or 0x7f800000'u32
        else:
            # NaN
            f = (uint32(sign) shl 31) or 0x7f800000'u32 or (uint32(mant) shl 13)
    else:
        # Normalized number
        var float_exp = uint32(exp + (127 - 15))
        var float_mant = uint32(mant) shl 13
        f = (uint32(sign) shl 31) or (float_exp shl 23) or float_mant
    return cast[float32](f)

proc readFloat32*(reader: CborReader): float32 =
    ## Reads four bytes from the CBOR data as a float32.
    bigEndian32(result.addr, reader.data[reader.pos].addr)
    inc reader.pos, 4

proc readFloat64*(reader: CborReader): float64 =
    ## Reads eight bytes from the CBOR data as a float64.
    bigEndian64(result.addr, reader.data[reader.pos].addr)
    inc reader.pos, 8

proc readBytes*(reader: CborReader, numberOfBytes: uint64): seq[uint8] =
    ## Reads the specified number of bytes from the CBOR data into a new sequence.
    result = reader.data[reader.pos..<reader.pos+numberOfBytes]
    reader.pos += numberOfBytes

proc readStr*(reader: CborReader, numberOfBytes: uint64): string {.noinit.} =
    ## Reads the specified number of bytes from the CBOR data into a new sequence.
    result = newStringOfCap(numberOfBytes)
    result.add(cast[seq[char]](reader.data).toOpenArray(reader.pos.int, (reader.pos+numberOfBytes - 1).int))
    reader.pos += numberOfBytes

proc readHead*(reader: CborReader): (HeadMajor, HeadArgument) =
    ## Reads the head of the CBOR data: the Major type and the argument (and no additional bytes).
    let firstByte = reader.readUInt8()
    let majorType = (firstByte shr 5).HeadMajor
    let argument = firstByte.masked(0b00011111'u8).HeadArgument
    return (majorType, argument)

proc getFullArgument*(reader: CborReader, shortArgument: HeadArgument): uint64 =
    ## Gets the full argument from the short argument.
    result = case shortArgument
        of Zero..TwentyThree: shortArgument.uint64
        of OneByte: reader.readUInt8().uint64
        of TwoBytes: reader.readUInt16().uint64
        of FourBytes: reader.readUInt32().uint64
        of EightBytes: reader.readUInt64().uint64
        else: raise newException(ValueError, "Invalid argument: " & $shortArgument)

proc isBreak*(head: tuple[major: HeadMajor, argument: HeadArgument]): bool =
    ## Checks if the head suggests a break of indefinite sequence.
    return head.major == Simple and head.argument == Indefinite

proc isIndefinite*(argument: HeadArgument): bool =
    ## Checks if the argument suggests an indefinite sequence.
    return argument == Indefinite

