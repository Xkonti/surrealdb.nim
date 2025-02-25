import std/[unittest]
import surreal/private/types/[surrealValue]

suite "SurrealValue:Future":

    test "can wrap and unwrap":
        let surrealValue = %%* ["Hi", "There", 42]
        let future = newFutureWrapper(surrealValue)
        check(future.kind == SurrealFuture)
        let unwrapped1 = future.unwrap()
        check(unwrapped1.kind == SurrealArray)
        check(unwrapped1 == surrealValue)
        let unwrapped2 = future.unwrapFuture()
        check(unwrapped2.kind == SurrealArray)
        check(unwrapped2 == surrealValue)
