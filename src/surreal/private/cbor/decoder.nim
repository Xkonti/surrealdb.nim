import ../types/[surrealValue]
import reader, types

proc decode*(reader: CborReader, head: tuple[major: HeadMajor, argument: HeadArgument]): SurrealValue =
    ## Decodes the raw CBOR data.

    let (headMajor, headArgument) = head

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
        # Text string
        let numberOfBytes = reader.getFullArgument(headArgument)
        var bytes: seq[uint8] = reader.readBytes(numberOfBytes)
        return bytes.toSurrealString()
    of 4:
        # Array
        # TODO: Handle indefinite length arrays
        var elements: seq[SurrealValue] = @[]
        let isIndefinite = headArgument.isIndefinite
        if isIndefinite:
            # Unknown number of elements
            while true:
                let head = reader.readHead()
                if head.isBreak:
                    break
                elements.add(decode(reader, head))
        else:
            # Known number of elements
            let numberOfElements = reader.getFullArgument(headArgument)
            for i in 0..<numberOfElements:
                let head = reader.readHead()
                elements.add(decode(reader, head))

        return elements.toSurrealArray()
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

proc decode*(reader: CborReader): SurrealValue =
    ## Decodes the raw CBOR data.
    let head = reader.readHead()
    return decode(reader, head)

proc decode*(data: openArray[uint8]): SurrealValue =
    ## Decodes the raw CBOR data.
    return decode(newCborReader(data))