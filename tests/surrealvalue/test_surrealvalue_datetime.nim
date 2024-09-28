import std/[times, unittest]
import surreal/private/types/[surrealValue]

suite "SurrealValue:DateTime":

    test "Can create from a DateTime":
        let datetime = now()
        let surrealValue = datetime.toSurrealDatetime()
        check(surrealValue.kind == SurrealDatetime)
        check(surrealValue.getDateTime == datetime)

        let surrealValue2 = %%% datetime
        check(surrealValue2.getDateTime == datetime)
        check(surrealValue2 == surrealValue)