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

    test "Can create from a Time":
        let time = now().toTime
        let surrealValue = time.toSurrealDatetime()
        check(surrealValue.kind == SurrealDatetime)
        check(surrealValue.getDateTime == time.utc())

    test "Can create from seconds and nanoseconds":
        var surrealValue = newSurrealDatetime(123456789'u64)
        check(surrealValue.kind == SurrealDatetime)
        check(surrealValue.getTime == initTime(123456789'i64, 0))

        surrealValue = newSurrealDatetime(150230021'u64, 125_041_003)
        check(surrealValue.kind == SurrealDatetime)
        check(surrealValue.getTime == initTime(150230021'i64, 125_041_003))

    test "Can compare datetimes":
        let datetime1 = dateTime(2024, mApr, 12, 6, 4, 2, 120_423_901, zone = utc()).toSurrealDatetime()
        let datetime2 = dateTime(2024, mApr, 12, 6, 4, 2, 120_423_901, zone = utc()).toSurrealDatetime()
        check(datetime1 == datetime2)
        check(datetime1.getTime == datetime2.getTime)
