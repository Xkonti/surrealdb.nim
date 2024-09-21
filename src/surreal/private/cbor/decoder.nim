import ../types/surrealValue
import reader

proc decode*(reader: CborReader): SurrealValue =
    ## Decodes the raw CBOR data.

    let (headMajor, headArgument) = reader.readHead()

    case headMajor
    of 0:
        # Positive integer
        let value = reader.getFullArgument(headArgument)
        return value.toSurrealInt()
    of 1:
        # Negative integer
        let value = reader.getFullArgument(headArgument)
        return toSurrealNegativeIntRaw(value)
    of 2:
        # Byte string
        let numberOfBytes = reader.getFullArgument(headArgument)
        var bytes: seq[uint8] = reader.readBytes(numberOfBytes)
        return bytes.toSurrealBytes()
    of 3:
        # TODO:Text string
        discard
    of 4:
        # TODO:Array
        discard
    of 5:
        # TODO:Map
        discard
    of 6:
        # TODO:Tag
        discard
    of 7:
        # TODO: Simple value
        discard

    return 69'u64.toSurrealInt()

proc decode*(data: openArray[uint8]): SurrealValue =
    ## Decodes the raw CBOR data.
    return decode(newCborReader(data))