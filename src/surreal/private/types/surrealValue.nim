import std/[strutils]
import surrealTypes

type
    SurrealValue* = ref object
        ## A SurrealDB-compatible value. This can be serialized to/from CBOR.
        case kind*: SurrealTypes
        of SurrealInteger:
            intVal*: uint64
            intIsNegative*: bool
        of SurrealBytes:
            bytesVal*: seq[uint8]
        of SurrealString:
            stringVal*: string
        of SurrealArray:
            arrayVal*: seq[SurrealValue]

include values/[
    integerValue,
    bytesValue,
    stringValue,
    arrayValue
    ]