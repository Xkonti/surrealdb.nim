import std/[macros]

type
    NoneType* = distinct bool
        ## Type representing the SurrealDB `NONE` value

macro None*(): NoneType =
    result = newCall(bindSym"NoneType", newLit(false))

proc `$`*(n: NoneType): string =
    "none"