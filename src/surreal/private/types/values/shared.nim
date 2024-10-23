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
        return $value.getDateTime()
    of SurrealDuration:
        return $value.durationVal.seconds & "s" & $value.durationVal.nanoseconds & "ns"
    of SurrealFloat:
        return case value.floatKind
            of Float32: $value.float32Val
            of Float64: $value.float64Val
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
    of SurrealRecordId:
        return $value.recordVal
    of SurrealString:
        return value.stringVal.escapeString
    of SurrealTable:
        return value.tableVal.string
    of SurrealUuid:
        let v = value.uuidVal
        return "u\"" &
          v[0].toHex & v[1].toHex & v[2].toHex & v[3].toHex &
            "-" & v[4].toHex & v[5].toHex &
            "-" & v[6].toHex & v[7].toHex &
            "-" & v[8].toHex & v[9].toHex &
            "-" & v[10].toHex & v[11].toHex & v[12].toHex & v[13].toHex & v[14].toHex & v[15].toHex &
          "\""

    else:
        raise newException(ValueError, "Cannot convert a $1 value to a string" % $value.kind)

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
