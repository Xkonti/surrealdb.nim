import std/[asyncdispatch, asyncfutures, json, strutils, tables]

import surreal/private/types/[none, null, queryParams, result, surql, surrealdb, surrealValue, surrealResult, tableName]
import surreal/private/logic/[connection]
import surreal/private/[queries]

export none, null, queryParams, result, surql, surrealdb, surrealResult, tableName
export connection
export queries


const shortStringBytes = @[
    0b0011_1111'u8, # Character '?'
    0b0010_0001'u8, # Character '!'
]

const shortString = "?!"

let stringFromBytes = cast[string](shortStringBytes)
for i in 0..<stringFromBytes.len:
    echo "Char ", i, ": ", stringFromBytes[i], " - as int: ", stringFromBytes[i].uint8
echo "String from bytes: ", stringFromBytes

let bytesFromString = cast[seq[uint8]](shortString)
echo "Bytes from string: ", bytesFromString

echo "Orig bytes == bytes from string: ", shortStringBytes == bytesFromString

echo "Short string == string from bytes: ", shortString == stringFromBytes