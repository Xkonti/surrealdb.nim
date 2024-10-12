import std/[macros, sequtils, strutils, tables, times]
import none, null, tableName
import ../utils

type
    SurrealTypes* = enum
        ## Supported Surreal types
        SurrealArray,
        SurrealBool,
        SurrealBytes,
        SurrealDatetime,
        SurrealFloat,
        SurrealInteger,
        SurrealNone,
        SurrealNull,
        SurrealObject,
        SurrealRecordId,
        SurrealString,
        SurrealTable,

        # TODO: There seem to be new Future and Range tags:
        # https://github.com/surrealdb/surrealdb/pull/4862
        # https://github.com/surrealdb/surrealdb.js/commit/278b17157c34987723ff8dca07cdeefeaa44c21e
        # SurrealFuture
        # SurrealRange

    SurrealObjectEntry* = tuple[key: string, value: SurrealValue]
        ## A single entry in a SurrealObject

    SurrealObjectTable* = OrderedTable[string, SurrealValue]
        ## A table of SurrealObject entries

    RecordId* = object
        ## A Surreal record ID. Consists of a table name and a record ID data.
        table*: TableName
        id*: SurrealValue

    SurrealValue* = ref object
        ## A SurrealDB-compatible value. This can be serialized to/from CBOR.
        case kind*: SurrealTypes
        of SurrealArray:
            arrayVal: seq[SurrealValue]
        of SurrealBool:
            boolVal: bool
        of SurrealBytes:
            bytesVal: seq[uint8]
        of SurrealDatetime:
            datetimeVal: DateTime
        of SurrealFloat:
            floatVal: float64
        of SurrealInteger:
            intVal: uint64
            intIsNegative: bool
        of SurrealNone:
            nil
        of SurrealNull:
            nil
        of SurrealObject:
            objectVal: SurrealObjectTable
        of SurrealRecordId:
            recordVal: RecordId
        of SurrealString:
            stringVal: string
        of SurrealTable:
            tableVal: TableName

include values/[
    array,
    bool,
    bytes,
    datetime,
    float,
    integer,
    none,
    null,
    map,
    string,
    table,

    record,

    shared
    ]

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
    of SurrealDatetime:
        return a.datetimeVal == b.datetimeVal
    of SurrealFloat:
        return a.floatVal == b.floatVal
    of SurrealInteger:
        return a.intVal == b.intVal and a.intIsNegative == b.intIsNegative
    of SurrealNone:
        return true
    of SurrealNull:
        return true
    of SurrealObject:
        return a.objectVal == b.objectVal
    of SurrealRecordId:
        return a.recordVal == b.recordVal
    of SurrealString:
        return a.stringVal == b.stringVal
    of SurrealTable:
        return a.tableVal == b.tableVal