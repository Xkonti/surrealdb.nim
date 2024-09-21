import surrealTypes

type
    SurrealValue* = ref object
        ## A SurrealDB-compatible value. This can be serialized to/from CBOR.
        case kind*: SurrealTypes
        of SurrealInteger:
            intVal*: uint64
            intIsNegative*: bool

include values/[integerValue]