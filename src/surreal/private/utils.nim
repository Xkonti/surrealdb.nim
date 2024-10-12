import std/[strutils]
import types/[tableName]

var nextId = 0 # TODO: Should be thread-safe (atomic int)

proc getNextId*(): string =
    ## Generates a new ID for a request.

    inc(nextId)
    return $nextId


proc canParseAsInt*(text: string): bool =
    ## Checks if the string can be parsed as an integer.
    # First character must be a didit or a minus
    if text[0] != '-' and not text[0].isDigit:
        return false

    # All other characters must be digits or a separator (`_`)
    # TODO: Verify that only the underscore is accepted as a separator
    for i in 1..<text.len:
        if not text[i].isDigit and text[i] != '_':
            return false
    return true


proc escapeInteger*(text: string): string =
    ## Escapes an integer so that it can be used within SurrealQL.
    if text.canParseAsInt:
        return text
    else:
        return "⟨" & text & "⟩"


proc escapeInteger*(value: uint64, isNegative: bool): string =
    ## Escapes an integer so that it can be used within SurrealQL.
    if isNegative:
        return "-" & $value
    else:
        return $value


proc escapeInteger*(value: int64): string =
    ## Escapes an integer so that it can be used within SurrealQL.
    return "⟨" & $value & "⟩"


proc escapeIdentifier*(text: string): string =
    ## Escapes a string identifier so that it can be used within SurrealQL.

    # String which looks like a number should always be escaped
    if text.canParseAsInt:
        return "⟨" & text & "⟩"

    # Only alphanumeric characters and underscores are allowed. Everything else needs to be escaped.
    for c in text:
        if not (c.isAlphaNumeric or c == '_'):
            return "⟨" & text.replace("⟩", "\\⟩") & "⟩"

    return text


proc escapeIdentifier*(table: TableName): string =
    ## Escapes a table name so that it can be used within SurrealQL.
    return escapeIdentifier(table.string)

proc escapeString*(text: string): string =
    ## Escapes a string so that it can be used within SurrealQL.
    return "⟨" & text.replace("⟩", "\\⟩") & "⟩"