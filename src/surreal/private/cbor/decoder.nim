import ../types/[surrealValue]
import reader, types

proc decode*(reader: CborReader, head: tuple[major: HeadMajor, argument: HeadArgument]): SurrealValue =
    ## Decodes the raw CBOR data.

    let (headMajor, headArgument) = head

    case headMajor
    of PosInt:
        # Positive integer
        let value = reader.getFullArgument(headArgument)
        return value.toSurrealInt()
    of NegInt:
        # Negative integer
        let value = reader.getFullArgument(headArgument)
        return toSurrealNegativeIntRaw(value)
    of Bytes:
        # Byte string
        let numberOfBytes = reader.getFullArgument(headArgument)
        var bytes: seq[uint8] = reader.readBytes(numberOfBytes)
        return bytes.toSurrealBytes()
    of String:
        # Text string
        let numberOfBytes = reader.getFullArgument(headArgument)
        var bytes: seq[uint8] = reader.readBytes(numberOfBytes)
        return bytes.toSurrealString()
    of Array:
        # Array
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
    of Map:
        # TODO:Map
        discard
    of Tag:
        # TODO:Tag
        discard
    of Simple:
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