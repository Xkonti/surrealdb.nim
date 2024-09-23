import ../stew/[endians2, sequtils2]

proc writeRawUInt*(buffer: var seq[uint8], value: uint8) =
    ## Writes an integer to the CBOR data.
    buffer.add(value)

proc writeRawUInt*(buffer: var seq[uint8], value: uint16 | uint32 | uint64) =
    ## Writes an integer to the CBOR data taking appropriate numver of bytes.
    buffer.write(value.toBytesBE)
