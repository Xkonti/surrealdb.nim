proc newSurrealObject*(): SurrealValue =
    ## Creates a new SurrealObject
    return SurrealValue(kind: SurrealObject, objectVal: initOrderedTable[string, SurrealValue]())

proc toSurrealObject*(value: SurrealObjectTable): SurrealValue =
    ## Converts a SurrealObjectTable to a SurrealObject
    return SurrealValue(kind: SurrealObject, objectVal: value)

proc toSurrealObject*(pairs: varargs[SurrealObjectEntry]): SurrealValue =
    ## Converts a sequence of tuples to a SurrealObject
    var table = initOrderedTable[string, SurrealValue]()
    for pair in pairs:
        table[pair.key] = pair.value
    return SurrealValue(kind: SurrealObject, objectVal: table)

proc `%%%`*(value: SurrealObjectTable): SurrealValue =
    ## Converts a SurrealObjectTable to a SurrealObject
    return toSurrealObject(value)

proc `%%%`*(pairs: openArray[SurrealObjectEntry]): SurrealValue =
    ## Converts a sequence of tuples to a SurrealObject
    return toSurrealObject(pairs)

proc getTable*(surrealObject: SurrealValue): SurrealObjectTable =
    ## Extracts the table (map) from the SurrealObject value.
    case surrealObject.kind
    of SurrealObject:
        return surrealObject.objectVal
    else:
        raise newException(ValueError, "Cannot extract the table from a $1 value" % $surrealObject.kind)

proc hasKey*(surrealObject: SurrealValue, key: string): bool =
    ## Checks if the SurrealObject has the specified key.
    case surrealObject.kind
    of SurrealObject:
        return surrealObject.objectVal.hasKey(key)
    else:
        raise newException(ValueError, "Cannot check the key in a $1 value" % $surrealObject.kind)

proc `[]`*(surrealObject: SurrealValue, key: string): SurrealValue =
    ## Extracts the value from the SurrealObject value.
    case surrealObject.kind
    of SurrealObject:
        return surrealObject.objectVal[key]
    else:
        raise newException(ValueError, "Cannot extract the value from a $1 value" % $surrealObject.kind)

proc `[]=`*(surrealObject: var SurrealValue, key: string, newValue: SurrealValue) =
    ## Adds a value to the SurrealObject value.
    case surrealObject.kind
    of SurrealObject:
        surrealObject.objectVal[key] = newValue
    else:
        raise newException(ValueError, "Cannot add a value to a $1 value" % $surrealObject.kind)

proc del*(surrealObject: var SurrealValue, key: string) =
    ## Removes the value from the SurrealObject value.
    case surrealObject.kind
    of SurrealObject:
        surrealObject.objectVal.del(key)
    else:
        raise newException(ValueError, "Cannot remove a value from a $1 value" % $surrealObject.kind)