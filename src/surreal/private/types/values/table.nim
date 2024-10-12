proc toSurrealTable*(value: TableName): SurrealValue =
    ## Converts a TableName to a SurrealTable
    return SurrealValue(kind: SurrealTable, tableVal: value)

proc toSurrealTable*(value: string): SurrealValue =
    ## Converts a string to a SurrealTable
    return SurrealValue(kind: SurrealTable, tableVal: value.TableName)

proc toSurrealTable*(value: openArray[uint8]): SurrealValue =
    ## Converts a sequence of bytes to a SurrealTable
    var text = cast[string](value.toSeq)
    return SurrealValue(kind: SurrealTable, tableVal: text.TableName)

proc `%%%`*(value: TableName): SurrealValue =
    ## Converts a TableName to a SurrealTable
    return toSurrealTable(value)

proc getTableName*(value: SurrealValue): TableName =
    ## Extracts the TableName value from the SurrealTable.
    case value.kind
    of SurrealTable:
        return value.tableVal
    else:
        raise newException(ValueError, "Cannot extract the TableName value from a $1 value" % $value.kind)