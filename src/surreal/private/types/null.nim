type
    NullType* = object
        ## Type representing the SurrealDB `NULL` value

const Null* : NullType = NullType()
    ## A Surreal NULL value

proc `$`*(n: NullType): string =
    ## Returns the string representation of the `Null` object.
    "NULL"