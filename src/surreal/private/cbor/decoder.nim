import std/[strutils, tables, times]
import ../types/[surrealValue, tableName]
import constants, reader, types

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
        return reader.readStr(numberOfBytes).toSurrealString()

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
        # TODO: Currently SurrealDB doesn't use tag numbers larger than 255 - room for optimization
        #       as potentially we don't have to have logic for reading 2, 4, or 8 byte-long values.
        let tag = reader.getFullArgument(headArgument).CborTag
        case tag:
        of TagDatetimeISO8601:
            # Datetime is encoded as a string
            let (stringHead, stringArgument) = reader.readHead()
            if stringHead != String:
                raise newException(ValueError, "Expected a string for a ISO8601 datetime (tag 0)")
            let numberOfBytes = reader.getFullArgument(stringArgument)
            let datetimeText = reader.readStr(numberOfBytes)
            return datetimeText.toSurrealDatetime()

        of TagNone:
            # NONE need a NULL value
            let shouldBeNullByte = reader.readUInt8()
            if shouldBeNullByte != nullByte:
                raise newException(ValueError, "Expected NULL byte for NONE (tag 6)")
            return surrealNone

        of TagTableName:
            # Table name is encoded as a string
            let (stringHead, stringArgument) = reader.readHead()
            if stringHead != String:
                raise newException(ValueError, "Expected a string for a Table Name (tag 7)")
            let numberOfBytes = reader.getFullArgument(stringArgument)
            var bytes = reader.readStr(numberOfBytes)
            return bytes.toSurrealTable()

        of TagRecordId:
            # Record ID is encoded as an array of two elements
            let (arrayHead, arrayArgument) = reader.readHead()
            if arrayHead != Array:
                raise newException(ValueError, "Expected an array for a Record ID (tag 8)")
            if arrayArgument != Two:
                raise newException(ValueError, "Expected an array of two elements for a Record ID (tag 8)")
            let (tableHead, tableArgument) = reader.readHead()
            if tableHead != String:
                raise newException(ValueError, "Expected a string for a table of a Record ID (tag 8)")
            let tableNameLength = reader.getFullArgument(tableArgument)
            let tableName = reader.readStr(tableNameLength).TableName
            let idPart = decode(reader, reader.readHead())
            return RecordId(table: tableName, id: idPart).toSurrealRecordId()
        
        of TagUuidString:
            # UUID encoded as a string
            let (stringHead, stringArgument) = reader.readHead()
            let numberOfBytes = reader.getFullArgument(stringArgument)
            # toSurrealUuid should oarse the string as a UUID
            return reader.readStr(numberOfBytes).toSurrealUuid()

        # TODO: Tag 10 - Decimal (string)
        
        of TagDatetimeCompact:
            # Datetime is encoded as an array of two numbers: seconds since epoch and nanoseconds
            let (arrayHead, arrayArgument) = reader.readHead()
            if arrayHead != Array:
                raise newException(ValueError, "Expected an array for a compact datetime (tag 12)")
            let arrayLength = reader.getFullArgument(arrayArgument)
            if arrayLength != 2:
                raise newException(ValueError, "Expected an array of two elements for a compact datetime (tag 12)")
            let (secondsHead, secondsArgument) = reader.readHead()
            if secondsHead != PosInt:
                raise newException(ValueError, "Expected a positive integer for the seconds part of a compact datetime (tag 12)")
            let seconds = reader.getFullArgument(secondsArgument)
            let (nanosecondsHead, nanosecondsArgument) = reader.readHead()
            if nanosecondsHead != PosInt:
                raise newException(ValueError, "Expected a positive integer for the nanoseconds part of a compact datetime (tag 12)")
            let nanoseconds = reader.getFullArgument(nanosecondsArgument)
            return newSurrealDatetime(seconds, nanoseconds.uint32)

        of TagUuidBinary:
            # UUID encoded as a sequence of 16 bytes
            let (bytesHead, bytesArgument) = reader.readHead()
            if bytesHead != Bytes or bytesArgument != Sixteen:
                raise newException(ValueError, "Expected a sequence of 16 bytes for a UUID (tag 37)")
            let bytes = reader.readBytes(16)
            return bytes.toSurrealUuid()

        else:
            raise newException(ValueError, "Tag not supported: " & $tag)

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
            # Read half-precision float as a float32
            return reader.readFloat16().toSurrealFloat()
        of FourBytes:
            return reader.readFloat32().toSurrealFloat()
        of EightBytes:
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
