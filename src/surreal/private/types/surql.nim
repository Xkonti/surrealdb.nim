type
    SurQL* = distinct string
        ## A Surreal query language string.

proc surql*(s: string): SurQL =
    ## Creates a new `SurQL` object from the specified string.
    return SurQL(s)