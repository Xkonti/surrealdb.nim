# This tests the %%% and %%* operators

import std/[sequtils, unittest]
import surreal/private/types/[none, null, surrealValue, tableName]

suite "SurrealValue:Parsing":

    test "%%* parses NONE values":
        let value = %%* NONE
        check(value.kind == SurrealNone)

    test "%%* parses NULL values":
        let value = %%* NULL
        check(value.kind == SurrealNull)

        let value2 = %%* nil
        check(value2.kind == SurrealNull)

    test "%%* parses boolean values":
        let value = %%* true
        check(value.kind == SurrealBool)
        check(value.getBool == true)

        let value2 = %%* false
        check(value2.kind == SurrealBool)
        check(value2.getBool == false)

    test "%%* parses integer values":
        let value = %%* 12
        check(value.kind == SurrealInteger)
        check(value.isPositive)
        check(value.toInt64 == 12)

        let value2 = %%* -12
        check(value2.kind == SurrealInteger)
        check(not value2.isPositive)
        check(value2.toInt64 == -12)

        let value3 = %%* 12_345
        check(value3.kind == SurrealInteger)
        check(value3.isPositive)
        check(value3.toInt64 == 12_345)

        let value4 = %%* -12_345
        check(value4.kind == SurrealInteger)
        check(not value4.isPositive)
        check(value4.toInt64 == -12_345)

    test "%%* parses float values":
        let value = %%* 12.5'f64
        check(value.kind == SurrealFloat)
        check(value.toFloat64 == 12.5'f64)

        let value2 = %%* -12.5'f64
        check(value2.kind == SurrealFloat)
        check(value2.toFloat64 == -12.5'f64)

    test "%%* parses string values":
        let value = %%* "Hello"
        check(value.kind == SurrealString)
        check(value.getString == "Hello")

        let value2 = %%* "Hello World"
        check(value2.kind == SurrealString)
        check(value2.getString == "Hello World")

    test "%%* parses bytes values":
        let value = %%* @[15'u8, 250'u8, 58'u8]
        check(value.kind == SurrealBytes)
        check(value.getBytes == @[15'u8, 250'u8, 58'u8])

    test "%%* parses table names":
        let value = %%* tb"user"
        check(value.kind == SurrealTable)
        check(value.getTableName == tb"user")

    test "%%* parses record IDs":
        let recordId = newRecordId(tb"book", "Equal Rites")
        let value = %%* recordId
        check(value.kind == SurrealRecordId)
        check(value.getRecordId == recordId)

    test "%%* parses array values":
        let value = %%* [12, 16.5'f64, "Goodbye moonmen", None]
        check(value.kind == SurrealArray)
        check(value.len == 4)
        check(value.getSeq[0].kind == SurrealInteger)
        check(value.getSeq[0].toInt64 == 12)
        check(value.getSeq[1].kind == SurrealFloat)
        check(value.getSeq[1].toFloat64 == 16.5'f64)
        check(value.getSeq[2].kind == SurrealString)
        check(value.getSeq[2].getString == "Goodbye moonmen")
        check(value.getSeq[3].kind == SurrealNone)

        let value2 = %%* [Null, @[1'u8, 2, 3, 4, 5]]
        check(value2.kind == SurrealArray)
        check(value2.len == 2)
        check(value2.getSeq[0].kind == SurrealNull)
        check(value2.getSeq[1].kind == SurrealBytes)
        check(value2.getSeq[1].getBytes == @[1'u8, 2, 3, 4, 5])

        let value3 = %%* []
        check(value3.kind == SurrealArray)
        check(value3.len == 0)

        let value4 = %%* ["Hi there", [12, 0.5'f64, [NONE, NONE, NULL]], "Bye"]
        check(value4.kind == SurrealArray)
        check(value4.len == 3)
        check(value4.getSeq[0].kind == SurrealString)
        check(value4.getSeq[0].getString == "Hi there")
        check(value4.getSeq[1].kind == SurrealArray)
        check(value4.getSeq[1].len == 3)
        check(value4.getSeq[1].getSeq[0].kind == SurrealInteger)
        check(value4.getSeq[1].getSeq[0].toInt64 == 12)
        check(value4.getSeq[1].getSeq[1].kind == SurrealFloat)
        check(value4.getSeq[1].getSeq[1].toFloat64 == 0.5'f64)
        check(value4.getSeq[1].getSeq[2].kind == SurrealArray)
        check(value4.getSeq[1].getSeq[2].len == 3)
        check(value4.getSeq[1].getSeq[2].getSeq[0].kind == SurrealNone)
        check(value4.getSeq[1].getSeq[2].getSeq[1].kind == SurrealNone)
        check(value4.getSeq[1].getSeq[2].getSeq[2].kind == SurrealNull)
        check(value4.getSeq[2].kind == SurrealString)
        check(value4.getSeq[2].getString == "Bye")

    test "%%* parses objects":
        let value = %%* {}
        check(value.kind == SurrealObject)
        check(value.len == 0)

        let value2 = %%* { "Hello": "World" }
        check(value2.kind == SurrealObject)
        check(value2.len == 1)
        check(value2.hasKey("Hello"))
        check(value2["Hello"].kind == SurrealString)
        check(value2["Hello"].getString == "World")

        let value3 = %%* {
            "name": "John",
            "age": 25,
            "pets": ["cat", "dog"],
            "preferences": { "food": true, "drink": 100 },
            "id": rc"customer:15923abbbcuwn"
        }
        check(value3.kind == SurrealObject)
        check(value3.len == 5)
        check(value3.hasKey("name"))
        check(value3["name"].kind == SurrealString)
        check(value3["name"].getString == "John")
        check(value3.hasKey("age"))
        check(value3["age"].kind == SurrealInteger)
        check(value3["age"].toInt64 == 25)
        check(value3.hasKey("pets"))
        check(value3["pets"].kind == SurrealArray)
        check(value3["pets"].len == 2)
        check(value3["pets"].getSeq[0].kind == SurrealString)
        check(value3["pets"].getSeq[0].getString == "cat")
        check(value3["pets"].getSeq[1].kind == SurrealString)
        check(value3["pets"].getSeq[1].getString == "dog")
        check(value3.hasKey("preferences"))
        check(value3["preferences"].kind == SurrealObject)
        check(value3["preferences"].len == 2)
        check(value3["preferences"].hasKey("food"))
        check(value3["preferences"]["food"].kind == SurrealBool)
        check(value3["preferences"]["food"].getBool == true)
        check(value3["preferences"].hasKey("drink"))
        check(value3["preferences"]["drink"].kind == SurrealInteger)
        check(value3["preferences"]["drink"].toInt64 == 100)
        check(value3.hasKey("id"))
        check(value3["id"].kind == SurrealRecordId)
        check(value3["id"].getRecordId.table == tb"customer")
        check(value3["id"].getRecordId.id.kind == SurrealString)
        check(value3["id"].getRecordId.id.getString == "15923abbbcuwn")