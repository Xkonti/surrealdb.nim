import std/[sequtils, strutils, tables]
import null

type
    SurrealTypes* = enum
        ## Supported Surreal types
        SurrealArray,
        SurrealBool,
        SurrealBytes,
        SurrealInteger,
        SurrealNull,
        SurrealObject,
        SurrealString,

        # TODO: There seem to be new Future and Range tags:
        # https://github.com/surrealdb/surrealdb/pull/4862
        # https://github.com/surrealdb/surrealdb.js/commit/278b17157c34987723ff8dca07cdeefeaa44c21e
        # SurrealFuture
        # SurrealRange

    SurrealObjectEntry* = tuple[key: string, value: SurrealValue]
        ## A single entry in a SurrealObject

    SurrealObjectTable* = OrderedTable[string, SurrealValue]
        ## A table of SurrealObject entries

    SurrealValue* = ref object
        ## A SurrealDB-compatible value. This can be serialized to/from CBOR.
        case kind*: SurrealTypes
        of SurrealArray:
            arrayVal: seq[SurrealValue]
        of SurrealBool:
            boolVal: bool
        of SurrealBytes:
            bytesVal: seq[uint8]
        of SurrealInteger:
            intVal: uint64
            intIsNegative: bool
        of SurrealNull:
            nil
        of SurrealObject:
            objectVal: SurrealObjectTable
        of SurrealString:
            stringVal: string

func `==`*(a, b: SurrealValue): bool =
    ## Compares two SurrealValues for equality.
    if a.kind != b.kind:
        return false

    case a.kind
    of SurrealArray:
        return a.arrayVal == b.arrayVal
    of SurrealBool:
        return a.boolVal == b.boolVal
    of SurrealBytes:
        return a.bytesVal == b.bytesVal
    of SurrealInteger:
        return a.intVal == b.intVal and a.intIsNegative == b.intIsNegative
    of SurrealNull:
        return true
    of SurrealObject:
        return a.objectVal == b.objectVal
    of SurrealString:
        return a.stringVal == b.stringVal


include values/[
    array,
    bool,
    bytes,
    integer,
    null,
    map,
    string,
    shared
    ]