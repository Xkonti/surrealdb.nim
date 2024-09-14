type
    SurQL* = distinct string

proc surql*(s: string): SurQL =
    return SurQL(s)