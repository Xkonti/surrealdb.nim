import std/[json]

type
    TableName* = distinct string
        ## A Surreal table name.

proc tb*(s: string): TableName =
    ## Creates a new table name object from the specified string.
    return TableName(s)

proc `==`*(a, b: TableName): bool =
    ## Compares two table names for equality.
    return a.string == b.string

proc `$`*(table: TableName): string =
    ## Returns the string representation of the table name.
    return table.string

proc `%*`*(table: TableName): JsonNode =
    ## Converts a record ID to a JSON object.
    return %* $table