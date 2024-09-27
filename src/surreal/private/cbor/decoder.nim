import std/[tables]
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
        # TODO: Support indefinite length byte strings
        let numberOfBytes = reader.getFullArgument(headArgument)
        var bytes: seq[uint8] = reader.readBytes(numberOfBytes)
        return bytes.toSurrealBytes()
    of String:
        # Text string
        # TODO: Support indefinite length text strings
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
        var map = initOrderedTable[string, SurrealValue]()
        let isIndefinite = headArgument.isIndefinite
        if isIndefinite:
            # unknown number of elements
            while true:
                let keyHead = reader.readHead()
                if keyHead.isBreak:
                    break
                 # TODO: Key can be extracted by something like `decodeString`
                 #       that avoids wrapping the string in a SurrealValue
                let key = decode(reader, keyHead)
                let value = decode(reader, reader.readHead())
                map[key.getString] = value
        else:
            # Known number of elements
            let numberOfElements = reader.getFullArgument(headArgument)
            for i in 0..<numberOfElements:
                # TODO: Key can be extracted by something like `decodeString`
                #       that avoids wrapping the string in a SurrealValue
                let key = decode(reader, reader.readHead())
                let value = decode(reader, reader.readHead())
                map[key.getString] = value

        return map.toSurrealObject()
    of Tag:
        # TODO:Tag
        raise newException(ValueError, "Tag not implemented")
    of Simple:
        case headArgument:
        of Twenty:
            return surrealFalse
        of TwentyOne:
            return surrealTrue
        of TwentyTwo:
            return surrealNull
        of TwentyThree:
            # Log error as SurrealDB isn't supposed to send `undefined`
            echo "WARNING: Undefined value received"
            return surrealNone
        of TwoBytes:
            # TODO: Support half-precision floats
            return reader.readFloat16().toSurrealFloat()
        of FourBytes:
            # TODO: Read 32-bit float
            return reader.readFloat32().toSurrealFloat()
        of EightBytes:
            # TODO: Read 64-bit float
            return reader.readFloat64().toSurrealFloat()
        else:
            raise newException(ValueError, "Invalid simple value: " & $headArgument)


proc decode*(reader: CborReader): SurrealValue =
    ## Decodes the raw CBOR data.
    let head = reader.readHead()
    return decode(reader, head)

proc decode*(data: openArray[uint8]): SurrealValue =
    ## Decodes the raw CBOR data.
    return decode(newCborReader(data))