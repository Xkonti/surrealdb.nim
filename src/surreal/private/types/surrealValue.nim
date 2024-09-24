import std/[sequtils, strutils]
import surrealTypes

type
    SurrealValue* = ref object
        ## A SurrealDB-compatible value. This can be serialized to/from CBOR.
        case kind*: SurrealTypes
        of SurrealInteger:
            intVal: uint64
            intIsNegative: bool
        of SurrealBytes:
            bytesVal: seq[uint8]
        of SurrealString:
            stringVal: string
        of SurrealArray:
            arrayVal: seq[SurrealValue]

func `==`*(a, b: SurrealValue): bool =
    ## Compares two SurrealValues for equality.
    if a.kind != b.kind:
        return false

    case a.kind
    of SurrealInteger:
        return a.intVal == b.intVal and a.intIsNegative == b.intIsNegative
    of SurrealBytes:
        return a.bytesVal == b.bytesVal
    of SurrealString:
        return a.stringVal == b.stringVal
    of SurrealArray:
        return a.arrayVal == b.arrayVal


include values/[
    integer,
    bytes,
    string,
    array,
    shared
    ]