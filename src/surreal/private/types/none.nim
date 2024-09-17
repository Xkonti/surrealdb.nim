import std/[macros]

type
    NoneType* = distinct bool
        ## Type representing the SurrealDB `NONE` value

macro None*(): NoneType =
    ## Creates a new `NoneType` object.
    result = newCall(bindSym"NoneType", newLit(false))

proc `$`*(n: NoneType): string =
    ## Returns the string representation of the `NoneType` object.
    "none"