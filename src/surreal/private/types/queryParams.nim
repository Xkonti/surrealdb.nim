import std/[json, strutils, tables]


type
    QueryParam* = tuple
        key: string
        value: string

    QueryParams* = object
        table: Table[string, string]


converter toQueryParamsTable*[T: static[int]](params: seq[QueryParam]): QueryParams =
    var table = initTable[string, string]()
    for param in params.items:
        table[param.key] = param.value
    return QueryParams(table: table)

converter toQueryParamsTable*[T: static[int]](params: array[0..T, QueryParam]): QueryParams =
    var table = initTable[string, string]()
    for param in params.items:
        table[param.key] = param.value
    return QueryParams(table: table)

proc `$`*(params: QueryParams): string =
    var sections: seq[string] = @[]
    for pair in params.table.pairs:
        sections.add("$" & pair[0] & ": " & $(%* pair[1]))
    return "{ " & sections.join(", ") & " }"

proc `[]`*(params: QueryParams, key: string): string =
    return params.table[key]

proc `[]=`*(params: var QueryParams, key: string, value: string) =
    params.table[key] = value

proc `%*`*(params: QueryParams): JsonNode =
    return %* params.table

iterator items*(params: QueryParams): QueryParam =
    for pair in params.table.pairs:
        yield (pair[0], pair[1])

iterator values*(params: QueryParams): string =
    for pair in params.table.pairs:
        yield pair[1]

iterator keys*(params: QueryParams): string =
    for pair in params.table.pairs:
        yield pair[0]