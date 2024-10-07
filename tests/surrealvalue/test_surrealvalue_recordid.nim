import std/[unittest]
import surreal/private/types/[surrealValue, tableName]

suite "SurrealValue:RecordId":

    test "can create from an explicit string":
        let record1 = newRecordId(tb"table1", "abcd")
        check(record1.table == tb"table1")
        check(record1.id.getString == "abcd")
        check($record1 == "table1:abcd")

        let record2 = newRecordId(tb"12345", "12-55-99928-abcd")
        check(record2.table == tb"12345")
        check(record2.id.getString == "12-55-99928-abcd")
        check($record2 == "⟨12345⟩:⟨12-55-99928-abcd⟩")

        let record3 = newRecordId(tb"20_50", "wololo5")
        check(record3.table == tb"20_50")
        check(record3.id.getString == "wololo5")
        check($record3 == "⟨20_50⟩:wololo5")

        let record4 = newRecordId(tb"ęćąśółźż", "[\"hi\", \"there\"]")
        check(record4.table == tb"ęćąśółźż")
        check(record4.id.getString == "[\"hi\", \"there\"]")
        check($record4 == "⟨ęćąśółźż⟩:⟨[\"hi\", \"there\"]⟩")

        let record5 = newRecordId(tb"user", "12_001")
        check(record5.table == tb"user")
        check(record5.id.getString == "12_001")
        check($record5 == "user:⟨12_001⟩")

    # test "can create from a string representation":
    #     let record1a = newRecordId("table1:abcd")
    #     let record1b = rc"table1:abcd"
    #     check(record1a.table == tb"table1")
    #     check(record1b.table == tb"table1")
    #     check(record1a.id.getString == "abcd")
    #     check(record1b.id.getString == "abcd")
    #     check($record1a == "table1:abcd")
    #     check($record1b == "table1:abcd")

    #     # TODO: Test cases where table is escaped
    #     # "⟨table1⟩:abcd"
    #     # TODO: Test cases where colon is escaped
    #     # "⟨ab:cd:ef⟩:hello"
    #     # TODO: Test cases where id is escaped
    #     # "table1:⟨abcd⟩"

    test "can create from an integer":
        let record1 = newRecordId(tb"table1", 12345)
        check(record1.table == tb"table1")
        check(record1.id.toInt64 == 12345)
        check($record1 == "table1:12345")

        let record2 = newRecordId(tb"table1", -12345'i64)
        check(record2.table == tb"table1")
        check(record2.id.toInt64 == -12345)
        check($record2 == "table1:-12345")

        let record3 = newRecordId(tb"table1", 6'u8)
        check(record3.table == tb"table1")
        check(record3.id.toInt64 == 6)
        check($record3 == "table1:6")

    # TODO: Test creating from a decimal
    # TODO: Test creating from a UUID

    test "can create from an array":
        let record1 = newRecordId(tb"table1", @[%%% 1, %%% 2, %%% 3])
        check(record1.table == tb"table1")
        check(record1.id.getSeq[0].toInt64 == 1'i64)
        check(record1.id.getSeq[1].toInt64 == 2'i64)
        check(record1.id.getSeq[2].toInt64 == 3'i64)
        check($record1 == "table1:[1,2,3]")

        let record2 = newRecordId(tb"table2", @[%%% 1, %%% @[%%% "hi", %%% 3, %%% 661], %%% 3])
        check(record2.table == tb"table2")
        check(record2.id.getSeq[0].toInt64 == 1'i64)
        check(record2.id.getSeq[1].getSeq[0].getString == "hi")
        check(record2.id.getSeq[1].getSeq[1].toInt64 == 3'i64)
        check(record2.id.getSeq[1].getSeq[2].toInt64 == 661'i64)
        check(record2.id.getSeq[2].toInt64 == 3'i64)
        check($record2 == "table2:[1,[⟨hi⟩,3,661],3]")

    test "can create from an object":
        let record1 = newRecordId(tb"table1", {"a": %%% -12.5, "b": %%% "hello"})
        check(record1.table == tb"table1")
        check(record1.id["a"].toFloat64 == -12.5'f64)
        check(record1.id["b"].getString == "hello")
        check($record1 == "table1:{⟨a⟩:-12.5,⟨b⟩:⟨hello⟩}")

    test "can compare Record IDs for equality":
        let record1a = newRecordId(tb"table1", "abcd")
        let record1b = newRecordId(tb"table1", "abcd")
        check(record1a == record1b)

        let record2a = newRecordId(tb"table2", %%% -123548).toSurrealRecordId
        let record2b = newRecordId(tb"table2", %%% -123548).toSurrealRecordId
        check(record2a == record2b)