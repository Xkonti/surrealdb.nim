import std/unittest
import surreal/private/stew/sequtils2
import surreal/private/cbor/[decoder, encoder, types]
import surreal/private/types/[surrealTypes, surrealValue]

suite "CBOR:Decoder:Strings":

    test "decode text string #1":
        const data = @[
            encodeHeadByte(String, 2.HeadArgument),
            0b0011_1111'u8, # Character '?'
            0b0010_0001'u8, # Character '!'
        ]
        let decoded = decode(data) # Casts: cast[string](value)
        check(decoded.kind == SurrealString) # True
        check(decoded.stringVal.len == 2) # True
        check(decoded.stringVal[0] == '?') # True
        check(decoded.stringVal[1] == '!') # True
        check($decoded == "?!") # False. It evaluates to "?!�"

    test "decode text string #2":
        const text: string = "Ginger: You know what the greatest tragedy is in the whole world?... It's all the people who never find out what it is they really want to do or what it is they're really good at. It's all the sons who become blacksmiths because their fathers were blacksmiths. It's all the people who could be really fantastic flute players who grow old and die without ever seeing a musical instrument, so they become bad plowmen instead. It's all the people with talents who never even find out. Maybe they are never even born in a time when it's even possible to find out. It's all the people who never get to know what it is that they can really be. It's all the wasted chances. -- Terry Pratchett, Moving Pictures"
        var data = encodeHead(String, text.len.uint64)
        data.write(text.toOpenArrayByte(0, text.high))

        let decoded = decode(data)
        check(decoded.kind == SurrealString)
        check(decoded.stringVal == text)
        check($decoded == text)