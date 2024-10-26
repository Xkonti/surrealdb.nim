import std/[unittest]
import surreal/private/types/[surrealValue]

suite "SurrealValue:Range":

    test "Can create a range from two SurrealValues and bounds":
        let startValue = %%% 12
        let endValue = %%% 150
        let rangeValue = newSurrealRange(startValue, endValue, true, false)
        check(rangeValue.kind == SurrealRange)
        check(rangeValue.getRangeStart() == startValue)
        check(rangeValue.getRangeEnd() == endValue)
        check(rangeValue.isRangeStartInclusive == true)
        check(rangeValue.isRangeEndInclusive == false)
        check(rangeValue.getRangeData() == (startValue, endValue, true, false))

    test "can compare ranges":
        let range1 = newSurrealRange(%%% -12.5'f64, %%% 8.9832'f64, false, true)
        let range2 = newSurrealRange(%%% -12.5'f64, %%% 8.9832'f64, false, true)
        check(range1 == range2)
