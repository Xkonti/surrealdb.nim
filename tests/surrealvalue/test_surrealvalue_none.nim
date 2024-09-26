import std/[unittest]
import surreal/private/types/[surrealValue, none]

suite "SurrealValue:None":

    test "Can get a static none value":
        let surrealValue = surrealNone
        check(surrealValue.kind == SurrealNone)
        check(surrealValue.toNone == None)

    test "Can be created from nothing":
        let surrealValue = newSurrealNone()
        check(surrealValue.kind == SurrealNone)
        check(surrealValue.toNone == None)
        check(surrealValue == surrealNone)

    test "Can be created from a none":
        let surrealValue = None.toSurrealNone()
        check(surrealValue.kind == SurrealNone)
        check(surrealValue.toNone == None)
        check(surrealValue == surrealNone)
        check(%%% None == surrealValue)
        check(%%% None == surrealNone)

    test "Can get the none value":
        let surrealValue = newSurrealNone()
        check(surrealValue.toNone == None)

    test "Can be compared to none":
        let surrealValue1 = newSurrealNone()
        let surrealValue2 = newSurrealNone()
        check(surrealValue1 == surrealValue2)
        check(surrealValue1 == None)
        check(None == surrealValue1)
        check(surrealValue2 == None)
        check(None == surrealValue2)
        check(None == None)