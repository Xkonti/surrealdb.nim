type
    NoneType* = object
        ## Type representing the SurrealDB `NONE` value

const None* : NoneType = NoneType()
    ## A Surreal NONE value

proc `$`*(n: NoneType): string =
    ## Returns the string representation of the `NoneType` object.
    "none"