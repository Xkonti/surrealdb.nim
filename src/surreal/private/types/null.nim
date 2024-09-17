import std/[macros]

type
    NullType* = distinct bool
        ## Type representing the SurrealDB `NULL` value


macro Null*(): NullType =
    ## Creates a new `NullType` object.
    result = newCall(bindSym"NullType", newLit(true))

proc `$`*(n: NullType): string =
    ## Returns the string representation of the `NullType` object.
    "null"