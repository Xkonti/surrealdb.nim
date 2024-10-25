import std/[macros, sequtils, strutils, tables, times]
import none, null, duration, tableName
import ../utils

import tinyre

type
    SurrealTypes* = enum
        ## Supported Surreal types
        SurrealArray,
        SurrealBool,
        SurrealBytes,
        SurrealDatetime,
        SurrealDuration,
        SurrealFloat,
        SurrealFuture,
        SurrealInteger,
        SurrealNone,
        SurrealNull,
        SurrealObject,
        SurrealRange,
        SurrealRecordId,
        SurrealString,
        SurrealTable,
        SurrealUuid,

        # TODO: There seem to be new Future and Range tags:
        # https://github.com/surrealdb/surrealdb/pull/4862
        # https://github.com/surrealdb/surrealdb.js/commit/278b17157c34987723ff8dca07cdeefeaa44c21e
        # SurrealFuture
        # SurrealRange

    SurrealFloatKind* = enum
        ## The kind of a SurrealFloat
        # Float16,
        Float32,
        Float64

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
            datetimeVal: Time
        of SurrealDuration:
            durationVal: SurrealDuration
        of SurrealFloat:
            case floatKind*: SurrealFloatKind
            of Float32:
                float32Val: float32
            of Float64:
                float64Val: float64
        of SurrealFuture:
            futureVal: SurrealValue
        of SurrealInteger:
            intVal: uint64
            intIsNegative: bool
        of SurrealNone:
            nil
        of SurrealNull:
            nil
        of SurrealObject:
            objectVal: SurrealObjectTable
        of SurrealRange:
            rangeStartVal: SurrealValue
            rangeEndVal: SurrealValue
            isRangeStartInclusive: bool
            isRangeEndInclusive: bool
        of SurrealRecordId:
            recordVal: RecordId
        of SurrealString:
            stringVal: string
        of SurrealTable:
            tableVal: TableName
        of SurrealUuid:
            uuidVal: array[16, uint8]

include values/[
    array,
    bool,
    bytes,
    datetime,
    duration,
    float,
    future,
    integer,
    none,
    null,
    map,
    range,
    string,
    table,
    uuid,

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
    of SurrealDuration:
        return a.durationVal == b.durationVal
    of SurrealFloat:
        if a.floatKind != b.floatKind:
            return false
        return case a.floatKind
            of Float32: a.float32Val == b.float32Val
            of Float64: a.float64Val == b.float64Val
    of SurrealFuture:
        return a.futureVal == b.futureVal
    of SurrealInteger:
        return a.intVal == b.intVal and a.intIsNegative == b.intIsNegative
    of SurrealNone:
        return true
    of SurrealNull:
        return true
    of SurrealObject:
        return a.objectVal == b.objectVal
    of SurrealRange:
        return
            a.isRangeStartInclusive == b.isRangeStartInclusive and
            a.isRangeEndInclusive == b.isRangeEndInclusive and
            a.rangeStartVal == b.rangeStartVal and
            a.rangeEndVal == b.rangeEndVal
    of SurrealRecordId:
        return a.recordVal == b.recordVal
    of SurrealString:
        return a.stringVal == b.stringVal
    of SurrealTable:
        return a.tableVal == b.tableVal
    of SurrealUuid:
        return a.uuidVal == b.uuidVal
