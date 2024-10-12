import std/[sequtils, unittest]
import surreal/private/types/[surrealValue]

suite "SurrealValue:Float":

    test "Can create from a float64":
        const value = 3.14159'f64
        let surrealValue = value.toSurrealFloat()
        check(surrealValue.kind == SurrealFloat)
        check(surrealValue.toFloat64 == value)

        let surrealValue2 = %%%value
        check(surrealValue2 == surrealValue)

    test "Can create from a float32":
        const value = 3.14159'f32
        let surrealValue = value.toSurrealFloat()
        check(surrealValue.kind == SurrealFloat)
        check(surrealValue.toFloat32 == value)

        let surrealValue2 = %%%value
        check(surrealValue2 == surrealValue)

    test "Can get the float64 value":
        const value = 3.14159'f64
        let surrealValue = value.toSurrealFloat()
        check(surrealValue.toFloat64 == value)

    test "Can get the float32 value":
        const value = 3.14159'f32
        let surrealValue = value.toSurrealFloat()
        check(surrealValue.toFloat32 == value)