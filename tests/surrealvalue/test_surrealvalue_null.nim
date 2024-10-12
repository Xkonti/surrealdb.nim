import std/[unittest]
import surreal/private/types/[surrealValue, null]

suite "SurrealValue:Null":

    test "Can get a static null value":
        let surrealValue = surrealNull
        check(surrealValue.kind == SurrealNull)
        check(surrealValue.toNull == Null)

    test "Can be created from nothing":
        let surrealValue = newSurrealNull()
        check(surrealValue.kind == SurrealNull)
        check(surrealValue.toNull == Null)
        check(surrealValue == surrealNull)

    test "Can be created from a null":
        let surrealValue = Null.toSurrealNull()
        check(surrealValue.kind == SurrealNull)
        check(surrealValue.toNull == Null)
        check(surrealValue == surrealNull)
        check(%%% Null == surrealValue)
        check(%%% Null == surrealNull)

    test "Can get the null value":
        let surrealValue = newSurrealNull()
        check(surrealValue.toNull == Null)

    test "Can be compared to null":
        let surrealValue1 = newSurrealNull()
        let surrealValue2 = newSurrealNull()
        check(surrealValue1 == surrealValue2)
        check(surrealValue1 == Null)
        check(Null == surrealValue1)
        check(surrealValue2 == Null)
        check(Null == surrealValue2)
        check(Null == Null)