
proc toSurrealUuid*(value: array[16, uint8]): SurrealValue =
    ## Converts a sequence of bytes to a SurrealUuid
    return SurrealValue(kind: SurrealUuid, uuidVal: value)

proc toSurrealUuid*(value: openArray[uint8]): SurrealValue =
    ## Converts a sequence of bytes to a SurrealUuid
    if value.len != 16:
        raise newException(ValueError, "UUID is expected to be of length of 16 bytes")
    let a: array[16, uint8] = [
        value[0], value[1], value[2], value[3],
        value[4], value[5], value[6], value[7],
        value[8], value[9], value[10], value[11],
        value[12], value[13], value[14], value[15]
    ]
    return SurrealValue(kind: SurrealUuid, uuidVal: a)

proc toSurrealUuid*(value: string): SurrealValue =
    ## Converts a string to a SurrealValue
    # Match UUUId format with regex
    let uuidParts = value.match(re"([0-9a-fA-F]{8})-?([0-9a-fA-F]{4})-?([0-9a-fA-F]{4})-?([0-9a-fA-F]{4})-?([0-9a-fA-F]{12})")
    if uuidParts.len != 1 + 5 or uuidParts[0].len == 0:
        raise newException(ValueError, "Invalid UUID format: " & value)
    # Parse hex character pairs into uint8s
    # TODO: This begs for optimization
    var a: array[16, uint8] = [
        parseHexInt(uuidParts[1][0..<2]).uint8,
        parseHexInt(uuidParts[1][2..<4]).uint8,
        parseHexInt(uuidParts[1][4..<6]).uint8,
        parseHexInt(uuidParts[1][6..<8]).uint8,
        parseHexInt(uuidParts[2][0..<2]).uint8,
        parseHexInt(uuidParts[2][2..<4]).uint8,
        parseHexInt(uuidParts[3][0..<2]).uint8,
        parseHexInt(uuidParts[3][2..<4]).uint8,
        parseHexInt(uuidParts[4][0..<2]).uint8,
        parseHexInt(uuidParts[4][2..<4]).uint8,
        parseHexInt(uuidParts[5][0..<2]).uint8,
        parseHexInt(uuidParts[5][2..<4]).uint8,
        parseHexInt(uuidParts[5][4..<6]).uint8,
        parseHexInt(uuidParts[5][6..<8]).uint8,
        parseHexInt(uuidParts[5][8..<10]).uint8,
        parseHexInt(uuidParts[5][10..<12]).uint8,
    ]
    return SurrealValue(kind: SurrealUuid, uuidVal: a)

proc uuid*(stringId: string): SurrealValue =
    ## Creates a new UUID object from a string representation.
    return stringId.toSurrealUuid()

proc getUuid*(value: SurrealValue): seq[uint8] =
    ## Converts bytes array from SurrealBytes
    case value.kind
    of SurrealUuid:
        return value.uuidVal.toSeq
    else:
        raise newException(ValueError, "The value is of type $1 and doesn't contain uuid bytes" % $value.kind)

let zeroUuid* = [0'u8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].toSurrealUuid
let maxUuid* = [255'u8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255].toSurrealUuid
