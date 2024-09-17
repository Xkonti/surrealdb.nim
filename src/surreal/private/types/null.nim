import std/[macros]

type
    NullType* = distinct bool
        ## Type representing the SurrealDB `NULL` value


macro Null*(): NullType =
    result = newCall(bindSym"NullType", newLit(true))

proc `$`*(n: NullType): string =
    "null"