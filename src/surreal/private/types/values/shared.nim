proc len*(value: SurrealValue): int =
    ## Returns the length of the bytes array.
    case value.kind
    of SurrealArray:
        return value.arrayVal.len
    of SurrealBytes:
        return value.bytesVal.len
    of SurrealString:
        return value.stringVal.len
    of SurrealObject:
        return value.objectVal.len
    of SurrealTable:
        return value.tableVal.string.len
    else:
        raise newException(ValueError, "Cannot get the length of a $1 value" % $value.kind)

proc toBytes*(value: SurrealValue): seq[uint8] =
    ## Converts a SurrealValue to a sequence of bytes.
    case value.kind
    of SurrealBytes:
        return value.bytesVal
    of SurrealString:
        return cast[seq[uint8]](value.stringVal)
    of SurrealTable:
        return cast[seq[uint8]](value.tableVal.string)
    else:
        raise newException(ValueError, "Cannot convert a $1 value to a sequence of bytes" % $value.kind)

proc toFloat64*(value: SurrealValue): float64 =
    ## Converts a SurrealFloat to a float.
    case value.kind
    of SurrealFloat:
        return case value.floatKind
            of Float32: value.float32Val.float64
            of Float64: value.float64Val
    of SurrealInteger:
        return value.toInt64.float64
    else:
        raise newException(ValueError, "Cannot convert a non-float value to a float")

proc toFloat32*(value: SurrealValue): float32 =
    ## Converts a SurrealFloat to a float.
    case value.kind
    of SurrealFloat:
        return case value.floatKind
            of Float32: value.float32Val
            of Float64: value.float64Val.float64
    of SurrealInteger:
        return value.toInt64.float32
    else:
        raise newException(ValueError, "Cannot convert a non-float value to a float")

proc `$`*(value: SurrealValue): string =
    ## Converts a SurrealValue to a string representation - mostly for debugging purposes.
    case value.kind
    of SurrealArray:
        case value.arrayVal.len:
        of 0: return "[]"
        of 1: return "[" & $value.arrayVal[0] & "]"
        else:
            var text = "[" & $value.arrayVal[0]
            for i in 1..<value.arrayVal.len:
                text = text & "," & $value.arrayVal[i]
            return text & "]"
    of SurrealBool:
        return $value.boolVal
    of SurrealBytes:
        return cast[string](value.bytesVal)
    of SurrealDatetime:
        # Print it as ISO 8601 string
        return "<datetime> \"" & $value.getDateTime() & "\""
    of SurrealDuration:
        return "<duration> \"" & $value.durationVal.seconds & "s" & $value.durationVal.nanoseconds & "ns\""
    of SurrealFloat:
        return case value.floatKind
            of Float32: $value.float32Val
            of Float64: $value.float64Val
    of SurrealFuture:
        return "<future> { " & $value.futureVal & " }"
    of SurrealInteger:
        # TODO: Handle large integers, including negative u64
        return $(value.toInt64)
    of SurrealNone:
        return "NONE"
    of SurrealNull:
        return "NULL"
    of SurrealObject:
        case value.objectVal.len:
        of 0: return "{}"
        of 1:
            let pair = value.objectVal.pairs.toSeq[0]
            return "{" & pair[0].escapeString & ":" & $pair[1] & "}"
        else:
            let pairs = value.objectVal.pairs.toSeq
            var text = "{" & pairs[0][0].escapeString & ":" & $pairs[0][1]
            for i in 1..<pairs.len:
                let pair = pairs[i]
                text = text & "," & pair[0].escapeString & ":" & $pair[1]
            return text & "}"
    of SurrealRange:
        let startBound = value.getStartBound
        let endBound = value.getEndBound
        let operator =
            case startBound:
            of Unbounded, Inclusive:
                case endBound:
                of Unbounded, Exclusive:
                    ".."
                of Inclusive:
                    "..="
            of Exclusive:
                case endBound:
                of Unbounded, Exclusive:
                    ">.."
                of Inclusive:
                    ">..="
        case startBound:
        of Inclusive, Exclusive:
            case endBound:
            of Inclusive, Exclusive:
                return "(" & $value.rangeStartVal & operator & $value.rangeEndVal & ")"
            of Unbounded:
                return "(" & $value.rangeStartVal & operator & ")"
        of Unbounded:
            case endBound:
            of Inclusive, Exclusive:
                return "(" & operator & $value.rangeEndVal & ")"
            of Unbounded:
                return "(" & operator & ")"
    of SurrealRecordId:
        return "<record> " & $value.recordVal
    of SurrealString:
        return value.stringVal.escapeString
    of SurrealTable:
        return "<table> \"" & value.tableVal.string & "\""
    of SurrealUuid:
        let v = value.uuidVal
        return "<uuid> \"" &
          v[0].toHex & v[1].toHex & v[2].toHex & v[3].toHex &
            "-" & v[4].toHex & v[5].toHex &
            "-" & v[6].toHex & v[7].toHex &
            "-" & v[8].toHex & v[9].toHex &
            "-" & v[10].toHex & v[11].toHex & v[12].toHex & v[13].toHex & v[14].toHex & v[15].toHex &
          "\""
    else:
        raise newException(ValueError, "Cannot convert a $1 value to a string" % $value.kind)


proc debugPrintSurrealValue*(value: SurrealValue): string =
    # Prints the provided SurrealValue to the console with verbose formatting
    case value.kind
    of SurrealArray:
        case value.arrayVal.len:
        of 0: return "<<SurrealArray>>[]"
        of 1: return "<<SurrealArray>>[" & value.arrayVal[0].debugPrintSurrealValue & "]"
        else:
            var text = "<<SurrealArray>>[" & value.arrayVal[0].debugPrintSurrealValue
            for i in 1..<value.arrayVal.len:
                text = text & "," & value.arrayVal[i].debugPrintSurrealValue
            return text & "]"
    of SurrealBool:
        return "<<SurrealBool>>" & $value.boolVal
    of SurrealBytes:
        return "<<SurrealBool>>" & cast[string](value.bytesVal)
    of SurrealDatetime:
        # Print it as ISO 8601 string
        return "<<SurrealDatatetime>>" & $value.getDateTime() & "\""
    of SurrealDuration:
        return "<<SurrealDuration>>" & $value.durationVal.seconds & "s" & $value.durationVal.nanoseconds & "ns\""
    of SurrealFloat:
        return case value.floatKind
            of Float32: "<<SurrealFloat32>>" & $value.float32Val
            of Float64: "<<SurrealFloat64>>" & $value.float64Val
    of SurrealFuture:
        return "<<SurrealFuture>>{ " & value.futureVal.debugPrintSurrealValue & " }"
    of SurrealInteger:
        # TODO: Handle large integers, including negative u64
        return "<<SurrealInteger>>" & $(value.toInt64)
    of SurrealNone:
        return "<<SurrealNone>>NONE"
    of SurrealNull:
        return "<<SurrealNull>>NULL"
    of SurrealObject:
        case value.objectVal.len:
        of 0: return "<<SurrealObject>>{}"
        of 1:
            let pair = value.objectVal.pairs.toSeq[0]
            return "<<SurrealObject>>{" & pair[0].escapeString & ":" & pair[1].debugPrintSurrealValue & "}"
        else:
            let pairs = value.objectVal.pairs.toSeq
            var text = "<<SurrealObject>>{" & pairs[0][0].escapeString & ":" & pairs[0][1].debugPrintSurrealValue
            for i in 1..<pairs.len:
                let pair = pairs[i]
                text = text & "," & pair[0].escapeString & ":" & pair[1].debugPrintSurrealValue
            return text & "}"
    of SurrealRange:
        let startBound = value.getStartBound
        let endBound = value.getEndBound
        let operator =
            case startBound:
            of Unbounded, Inclusive:
                case endBound:
                of Unbounded, Exclusive:
                    ".."
                of Inclusive:
                    "..="
            of Exclusive:
                case endBound:
                of Unbounded, Exclusive:
                    ">.."
                of Inclusive:
                    ">..="
        case startBound:
        of Inclusive, Exclusive:
            case endBound:
            of Inclusive, Exclusive:
                return "<<SurrealRange>>(" & value.rangeStartVal.debugPrintSurrealValue & operator & value.rangeEndVal.debugPrintSurrealValue & ")"
            of Unbounded:
                return "<<SurrealRange>>(" & value.rangeStartVal.debugPrintSurrealValue & operator & "UNBOUNDED)"
        of Unbounded:
            case endBound:
            of Inclusive, Exclusive:
                return "<<SurrealRange>>(UNBOUNDED" & operator & value.rangeEndVal.debugPrintSurrealValue & ")"
            of Unbounded:
                return "<<SurrealRange>>(UNBOUNDED" & operator & "UNBOUNDED)"
    of SurrealRecordId:
        return "<<SurrealRecordId>>(" & $value.recordVal & ")"
    of SurrealString:
        return "<<SurrealString>>" & value.stringVal.escapeString
    of SurrealTable:
        return "<<SurrealTable>>\"" & value.tableVal.string & "\""
    of SurrealUuid:
        let v = value.uuidVal
        return "<<SurrealUuid>>\"" &
          v[0].toHex & v[1].toHex & v[2].toHex & v[3].toHex &
            "-" & v[4].toHex & v[5].toHex &
            "-" & v[6].toHex & v[7].toHex &
            "-" & v[8].toHex & v[9].toHex &
            "-" & v[10].toHex & v[11].toHex & v[12].toHex & v[13].toHex & v[14].toHex & v[15].toHex &
          "\""
    else:
        raise newException(ValueError, "Cannot convert a $1 value to a string debug representation" % $value.kind)


template `%%%`*(v: SurrealValue): SurrealValue = v

# template `%%*`*(v: SurrealValue): SurrealValue = v

proc toSurrealValueImpl(x: NimNode): NimNode =
  case x.kind
  of nnkBracket: # array
    if x.len == 0: return newCall(bindSym"newSurrealArray")
    result = newNimNode(nnkBracket)
    for i in 0 ..< x.len:
      result.add(toSurrealValueImpl(x[i]))
    result = newCall(bindSym("%%%", brOpen), result)
  of nnkTableConstr: # object
    if x.len == 0: return newCall(bindSym"newSurrealObject")
    result = newNimNode(nnkTableConstr)
    for i in 0 ..< x.len:
      x[i].expectKind nnkExprColonExpr
      result.add newTree(nnkExprColonExpr, x[i][0], toSurrealValueImpl(x[i][1]))
    result = newCall(bindSym("%%%", brOpen), result)
  of nnkCurly: # empty object
    x.expectLen(0)
    result = newCall(bindSym"newSurrealObject")
  of nnkNilLit:
    result = newCall(bindSym"newSurrealNull")
  of nnkPar:
    if x.len == 1: result = toSurrealValueImpl(x[0])
    else: result = newCall(bindSym("%%%", brOpen), x)
  else:
    result = newCall(bindSym("%%%", brOpen), x)

macro `%%*`*(x: untyped): untyped =
  ## Convert an expression to a SurrealValue directly, without having to specify
  ## `%%%` for every element.
  result = toSurrealValueImpl(x)
