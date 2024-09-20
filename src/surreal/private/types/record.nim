import std/[json, strutils]
import tableName

type
    RecordIdObj* = object
        ## A Surreal record ID. Consists of a table name and a record ID data.

        table: TableName
        id: string
        stringRepr: string

    RecordId* = ref RecordIdObj


proc extractDataFromString*(id: RecordId) =
    if id.stringRepr.len == 0:
        raise newException(ValueError, "Invalid record ID format: " & id.stringRepr)
    # Get position of the first colon
    let colonPos = id.stringRepr.find(":")
    if colonPos == -1:
        raise newException(ValueError, "Invalid record ID format: " & id.stringRepr)
    # Extract the table name
    id.table = id.stringRepr[0..<colonPos].TableName
    # Extract the record ID data
    id.id = id.stringRepr[colonPos+1..^1]


proc table*(id: RecordId): TableName =
    ## Returns the table name of the record ID.
    if id.table.string.len == 0:
        id.extractDataFromString
    return id.table


proc id*(id: RecordId): string =
    ## Returns the record ID data of the record ID.
    if id.id.len == 0:
        id.extractDataFromString
    return id.id


proc `$`*(id: RecordId): string =
    ## Returns the string representation of the record ID.
    if id.stringRepr.len == 0:
        id.stringRepr = $id.table & ":" & id.id
    return id.stringRepr


proc `==`*(a, b: RecordId): bool =
    ## Compares two record IDs for equality.
    return a.table == b.table and a.id == b.id


proc `%*`*(id: RecordId): JsonNode =
    ## Converts a record ID to a JSON object.
    return %* $id


proc newRecordId*(table: TableName, id: string): RecordId =
    ## Creates a new record ID object.
    return RecordId(table: table, id: id)


proc newRecordId*(stringRepr = string): RecordId =
    ## Creates a new record ID object from a string representation.
    return RecordId(stringRepr: stringRepr)


proc rc*(stringId: string): RecordId =
    ## A string literal that creates a new record ID
    return RecordId(stringRepr: stringId)