import std/unittest
import surreal/private/cbor/[decoder, encoder, types, writer]
import surreal/private/types/[surrealValue]

suite "CBOR:Decoder:Strings":

    test "decode text string #1":
        const data = @[
            encodeHeadByte(String, 2.HeadArgument),
            0b0011_1111'u8, # Character '?'
            0b0010_0001'u8, # Character '!'
        ]
        let decoded = decode(data)
        check(decoded.kind == SurrealString)
        check(decoded.len == 2)
        check(decoded.getString[0] == '?')
        check(decoded.getString[1] == '!')
        check($decoded == "?!")

    test "decode text string #2":
        const text: string = "Ginger: You know what the greatest tragedy is in the whole world?... It's all the people who never find out what it is they really want to do or what it is they're really good at. It's all the sons who become blacksmiths because their fathers were blacksmiths. It's all the people who could be really fantastic flute players who grow old and die without ever seeing a musical instrument, so they become bad plowmen instead. It's all the people with talents who never even find out. Maybe they are never even born in a time when it's even possible to find out. It's all the people who never get to know what it is that they can really be. It's all the wasted chances. -- Terry Pratchett, Moving Pictures"
        let writer = newCborWriter()
        writer.encodeHead(String, text.len.uint64)
        writer.writeBytes(text.toOpenArrayByte(0, text.high)) # TODO: Try casting instead. Which is faster?

        let decoded = decode(writer.getOutput())
        check(decoded.kind == SurrealString)
        check(decoded.getString == text)
        check($decoded == text)