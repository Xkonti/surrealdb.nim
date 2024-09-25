import std/[sequtils, unittest]
import surreal/private/types/[surrealValue]

suite "SurrealValue:Bool":

    test "Can create from a bool":
        let trueValue = true.toSurrealBool()
        check(trueValue.kind == SurrealBool)
        check(trueValue.getBool == true)

        let falseValue = false.toSurrealBool()
        check(falseValue.kind == SurrealBool)
        check(falseValue.getBool == false)

        check(trueValue == %%% true)
        check(falseValue == %%% false)

    test "Can use the cached true and false values":
        let trueValue = surrealTrue
        check(trueValue.kind == SurrealBool)
        check(trueValue.getBool == true)

        let falseValue = surrealFalse
        check(falseValue.kind == SurrealBool)
        check(falseValue.getBool == false)

        check(trueValue == %%% true)
        check(falseValue == %%% false)

    test "Can negate a bool":
        check(not surrealTrue == surrealFalse)
        check(not surrealFalse == surrealTrue)

        check(not %%% true == %%% false)
        check(not %%% false == %%% true)

        check(not true.toSurrealBool() == false.toSurrealBool())
        check(not false.toSurrealBool() == true.toSurrealBool())

        check(not surrealTrue == false.toSurrealBool())
        check(not surrealFalse == true.toSurrealBool())

        check(not %%% true == false.toSurrealBool())
        check(not %%% false == true.toSurrealBool())