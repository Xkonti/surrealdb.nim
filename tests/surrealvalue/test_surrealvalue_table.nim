import std/[unittest]
import surreal/private/types/[surrealValue, tableName]

suite "SurrealValue:Table":

    # test "Can not create from an empty string":
    #     discard # TODO: Implement

    test "Can create from a TableName":
        let table = tb"user"
        let surrealValue = table.toSurrealTable()
        check(surrealValue.kind == SurrealTable)
        check(surrealValue.getTableName == table)

        let surrealValue2 = %%% table
        check(surrealValue2.getTableName == table)
        check(surrealValue2 == surrealValue)

    test "Can create from a string":
        let table = "user"
        let surrealValue = table.toSurrealTable()
        check(surrealValue.kind == SurrealTable)
        check(surrealValue.getTableName == table.TableName)

    test "Can get the TableName value":
        let table = tb"user"
        let surrealValue = table.toSurrealTable()
        check(surrealValue.getTableName == table)

        let table2 = "product".TableName
        let surrealValue2 = %%% table2
        check(surrealValue2.getTableName == table2)
        check(surrealValue2.getTableName == table2)
