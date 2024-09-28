type
    HeadMajor* = enum
        PosInt = 0,
        NegInt = 1,
        Bytes = 2,
        String = 3,
        Array = 4,
        Map = 5,
        Tag = 6,
        Simple = 7
        ## A value of the Major CBOR type.

    HeadArgument* = enum
        ## A value of the argument of the Major CBOR type.
        Zero = 0,
        One = 1,
        Two = 2,
        Three = 3,
        Four = 4,
        Five = 5,
        Six = 6,
        Seven = 7,
        Eight = 8,
        Nine = 9,
        Ten = 10,
        Eleven = 11,
        Twelve = 12,
        Thirteen = 13,
        Fourteen = 14,
        Fifteen = 15,
        Sixteen = 16,
        Seventeen = 17,
        Eighteen = 18,
        Nineteen = 19,
        Twenty = 20,
        TwentyOne = 21,
        TwentyTwo = 22,
        TwentyThree = 23,

        OneByte = 24,
        TwoBytes = 25,
        FourBytes = 26,
        EightBytes = 27,

        Reserved28 = 28,
        Reserved29 = 29,
        Reserved30 = 30,

        Indefinite = 31

    CborTag* = enum
        # CBOR tag number supported by SurrealDB
        TagDatetimeISO8601 = 0'u64, # From the spec - https://www.iana.org/assignments/cbor-tags/cbor-tags.xhtml
        TagNone = 6'u64,
        TagTableName = 7'u64,
        TagRecordId = 8'u64,
        TagUuidString = 9'u64,
        TagDecimalString = 10'u64,
        # TagDecimalBinary = 11'u64,
        TagDateTimeCompact = 12'u64,
        TagDurationString = 13'u64,
        TagDurationCompact = 14'u64,
        TagFuture = 15'u64,
        TagUuidBinary = 37'u64, # From the spec - https://www.iana.org/assignments/cbor-tags/cbor-tags.xhtml

        # Ranges
        TagRange = 49'u64,
        TagBoundIncluded = 50'u64,
        TagBoundExcluded = 51'u64,

        TagGeoPoint = 88'u64,
        TagGeoLine = 89'u64,
        TagGeoPolygon = 90'u64,
        TagGeoMultiPoint = 91'u64,
        TagGeoMultiLine = 92'u64,
        TagGeoMultiPolygon = 93'u64,
        TagGeoCollection = 94'u64,