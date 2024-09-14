type
    NoneType* = distinct bool
    NullType* = distinct bool


macro Null*(): NullType =
  result = newCall(bindSym"NullType", newLit(true))

# For debugging purposes, you might want to add this:
proc `$`*(n: NullType): string = 
  "null"

macro None*(): NoneType =
  result = newCall(bindSym"NoneType", newLit(false))

# For debugging purposes, you might want to add this:
proc `$`*(n: NoneType): string = 
  "none"