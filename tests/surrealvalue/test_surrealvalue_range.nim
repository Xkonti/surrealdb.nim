import std/[unittest]
import surreal/private/types/[surrealValue]

suite "SurrealValue:Range":

    test "can create range with both bounds":
        let startValue = %%% 12
        let endValue = %%% 150
        let rangeValue = newSurrealRange(startValue, endValue, true, false)
        check(rangeValue.kind == SurrealRange)
        check(rangeValue.getRangeStart() == startValue)
        check(rangeValue.getRangeEnd() == endValue)
        check(rangeValue.getStartBound() == Inclusive)
        check(rangeValue.getEndBound() == Exclusive)

    test "can create range with only start bound":
        let startValue = %%* [12]
        let rangeValue = newSurrealStartOnlyRange(startValue, false)
        check(rangeValue.kind == SurrealRange)
        check(rangeValue.getRangeStart() == startValue)
        check(rangeValue.getRangeEnd() == surrealNone)
        check(rangeValue.getStartBound() == Exclusive)
        check(rangeValue.getEndBound() == Unbounded)

    test "can create range with only end bound":
        let endValue = %%* { "value": 5812 }
        let rangeValue = newSurrealEndOnlyRange(endValue, true)
        check(rangeValue.kind == SurrealRange)
        check(rangeValue.getRangeStart() == surrealNone)
        check(rangeValue.getRangeEnd() == endValue)
        check(rangeValue.getStartBound() == Unbounded)
        check(rangeValue.getEndBound() == Inclusive)

    test "can compare ranges":
        let range1 = newSurrealRange(%%% -12.5'f64, %%% 8.9832'f64, false, true)
        let range2 = newSurrealRange(%%% -12.5'f64, %%% 8.9832'f64, false, true)
        check(range1 == range2)

        let range3 = newSurrealStartOnlyRange(%%% "Howdy", true)
        let range4 = newSurrealStartOnlyRange(%%% "Howdy", true)
        check(range3 == range4)

        let range5 = newSurrealEndOnlyRange(%%% "Sayonara", false)
        let range6 = newSurrealEndOnlyRange(%%% "Sayonara", false)
        check(range5 == range6)
