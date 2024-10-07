proc toSurrealRecordId*(value: RecordId): SurrealValue =
    ## Converts a RecordId to a SurrealRecordId
    return SurrealValue(kind: SurrealRecordId, recordVal: value)

proc `%%%`*(value: RecordId): SurrealValue =
    ## Converts a RecordId to a SurrealRecordId
    return toSurrealRecordId(value)

proc getRecordId*(surrealRecordId: SurrealValue): RecordId =
    ## Extracts the record ID from the SurrealRecordId value.
    case surrealRecordId.kind
    of SurrealRecordId:
        return surrealRecordId.recordVal
    else:
        raise newException(ValueError, "Cannot extract the record ID from a $1 value" % $surrealRecordId.kind)

proc extractDataFromString*(data: string): (TableName, SurrealValue) =
    ## Extracts the table name and record ID data from a string representation of a record ID.
    ## This assumes that the ID is purely a string. It doesn't check if it's a number, array, etc.

    # Get position of the first colon
    let colonPos = data.find(":")
    if colonPos == -1:
        raise newException(ValueError, "Invalid record ID format: " & data)
    # Extract the table name
    let table = data[0..<colonPos].TableName
    # Extract the record ID data
    let value = data[colonPos+1..^1].toSurrealString
    return (table, value)

proc `$`*(value: SurrealValue): string # Forward declaration as RecordId's `$` needs it

proc escapeIdPart*(id: SurrealValue): string =
    ## Escapes the ID part of a Record ID.
    case id.kind
    of SurrealArray, SurrealObject:
        return $id
    of SurrealString:
        return escapeIdentifier(id.getString)
    of SurrealInteger:
        if id.isNegative:
            return escapeInteger(id.getRawInt + 1, true)
        return escapeInteger(id.getRawInt, false)
    # TODO: Support decimals (bigint)
    # of SurrealDecimal:
    #     return escapeDecimal(id.getDecimal)
    # TODO: Support UUIDs
    # of SurrealUuid:
    #     return "`u\"" & id.getUuid & "\"`"
    else:
        raise newException(ValueError, "Cannot escape the ID part of a record ID from a $1 value" % $id.kind)

proc `$`*(id: RecordId): string =
    ## Returns the string representation of the record ID.
    let escapedTable = escapeIdentifier(id.table)
    let escapedId = escapeIdPart(id.id)
    return escapedTable & ":" & escapedId

func `==`*(a, b: SurrealValue): bool # Forward declaration as RecordId's `==` needs it

func `==`*(a, b: RecordId): bool =
    ## Compares two record IDs for equality.
    if a.table != b.table:
        return false
    return a.id == b.id


proc newRecordId*(table: TableName, id: string): RecordId =
    ## Creates a new record ID object.
    return RecordId(table: table, id: id.toSurrealString)

proc newRecordId*(table: TableName, id: SomeInteger): RecordId =
    ## Creates a new record ID object.
    return RecordId(table: table, id: id.toSurrealInt)

proc newRecordId*(table: TableName, id: varargs[SurrealValue, `%%%`]): RecordId =
    ## Creates a new record ID object.
    return RecordId(table: table, id: id.toSurrealArray)

proc newRecordId*(table: TableName, id: varargs[SurrealObjectEntry]): RecordId =
    ## Creates a new record ID object.
    return RecordId(table: table, id: id.toSurrealObject)

proc newRecordId*(table: TableName, id: SurrealObjectTable): RecordId =
    ## Creates a new record ID object.
    return RecordId(table: table, id: id.toSurrealObject)

proc newRecordId*(table: TableName, id: SurrealValue): RecordId =
    ## Creates a new record ID object.
    case id.kind
    of SurrealString, SurrealInteger, SurrealArray, SurrealObject:
        return RecordId(table: table, id: id)
    else:
        raise newException(ValueError, "Cannot create a record ID from a $1 value" % $id.kind)


# proc newRecordId*(stringRepr: string): RecordId =
#     ## Creates a new record ID object from a string representation.
#     ## This assumes that the ID is purely a string. It doesn't check if it's a number, array, etc.
#     let (table, id) = extractDataFromString(stringRepr)
#     return RecordId(table: table, id: id)


# proc rc*(stringId: string): RecordId =
#     ## A string literal that creates a new record ID
#     return newRecordId(stringId)