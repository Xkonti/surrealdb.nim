import writer, types

proc encodeHeadByte*(major: HeadMajor, argument: HeadArgument): uint8 =
    ## Encodes the first byte of the head of the CBOR data.
    return (major.uint8 shl 5) or argument.uint8

proc encodeHead*(major: HeadMajor, length: uint64): seq[uint8] =
    ## Encodes the head of the CBOR data with the specified length of content.
    let head: uint8 = (major.uint8 shl 5)
    if length < 24:
        return @[head.uint8 or length.uint8]
    elif length < uint8.high:
        return @[head.uint8 or 24, length.uint8]
    elif length < uint16.high:
        var bytes = @[head.uint8 or 25]
        bytes.writeRawUInt(length.uint16)
        return bytes
    elif length < uint32.high:
        var bytes = @[head.uint8 or 26]
        bytes.writeRawUInt(length.uint32)
        return bytes
    else:
        var bytes = @[head.uint8 or 27]
        bytes.writeRawUInt(length.uint64)
        return bytes