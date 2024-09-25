import std/[sequtils, unittest, tables]
import surreal/private/types/[surrealTypes, surrealValue]

suite "SurrealValue:Object":

    test "Can create an empty object":
        let surrealValue = newSurrealObject()
        check(surrealValue.kind == SurrealObject)
        check(surrealValue.len == 0)
        check(surrealValue.getTable.len == 0)


    test "Can be created from an empty table":
        let table = initOrderedTable[string, SurrealValue]()
        let surrealValue = table.toSurrealObject()
        check(surrealValue.kind == SurrealObject)
        check(surrealValue.len == 0)
        check(surrealValue.getTable.len == 0)

    test "Can be created from an empty sequence of tuples":
        let table: seq[tuple[key: string, value: SurrealValue]] = @[]
        let surrealValue = table.toSurrealObject()
        check(surrealValue.kind == SurrealObject)
        check(surrealValue.len == 0)
        check(surrealValue.getTable.len == 0)

    test "Can be created from a table":
        let table: SurrealObjectTable = {
                "Hello": %%% "World",
                "Number": %%% 12
            }.toOrderedTable
        let surrealValue = table.toSurrealObject()
        check(surrealValue.kind == SurrealObject)
        check(surrealValue.len == 2)
        check(surrealValue.getTable == table)
        check(%%%table == surrealValue)

    test "Can be created from a sequence of tuples":
        let sequence: seq[tuple[key: string, value: SurrealValue]] = @[
            ("Hello", %%% "World"),
            ("Number", %%% 12)
        ]
        let surrealValue = sequence.toSurrealObject()
        check(surrealValue.kind == SurrealObject)
        check(surrealValue.len == 2)
        check(surrealValue.getTable == sequence.toOrderedTable)

    test "Can set and check a value to the object":
        # Set value
        var surrealValue = newSurrealObject()
        check(surrealValue.len == 0)
        surrealValue["Answer"] = %%% 42
        check(surrealValue.len == 1)
        check(surrealValue.getTable["Answer"] == %%% 42)
        check(surrealValue.hasKey("Answer") == true)
        check(surrealValue.hasKey("id") == false)

        # Set another value
        surrealValue["id"] = %%% "hello:there"
        check(surrealValue.len == 2)
        check(surrealValue.getTable["id"] == %%% "hello:there")
        check(surrealValue.hasKey("Answer") == true)
        check(surrealValue.hasKey("id") == true)

        # Check the values
        check(surrealValue["Answer"] == %%% 42)
        check(surrealValue["id"] == %%% "hello:there")

        # Override a value
        surrealValue["Answer"] = %%% 23
        check(surrealValue.len == 2)
        check(surrealValue.getTable["Answer"] == %%% 23)
        check(surrealValue.getTable["id"] == %%% "hello:there")
        check(surrealValue["Answer"] == %%% 23)
        check(surrealValue["id"] == %%% "hello:there")
        check(surrealValue.hasKey("Answer") == true)
        check(surrealValue.hasKey("id") == true)

        # Remove a value
        surrealValue.del("id")
        check(surrealValue.len == 1)
        check(surrealValue.hasKey("Answer") == true)
        check(surrealValue.hasKey("id") == false)
        check(surrealValue.getTable["Answer"] == %%% 23)