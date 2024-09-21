import std/[asyncdispatch, asyncfutures, json, strutils, tables]
import surreal/private/[queries]
import surreal/private/types/[record, tableName]
import surreal/private/logic/[connection]

import surreal/private/cbor/[gap, decoder]

proc main() {.async.} =
    # let ws = await newAsyncWebsocketClient("jabba.lan", Port(14831),
    #   path = "/rpc", protocols = @["cbor"])   protocol = "alpha"
    # echo "connected!"

    echo "Connecting to SurrealDB..."
    let surreal = await newSurrealDbConnection("ws://jabba.lan:14831/rpc")

    let ns = "test"
    let db = "test"
    discard await surreal.use(ns, db)
    echo "Switched to namespace '", ns, "' and database '", db, "'"

    let signinResponse = await surreal.signin("disjoin4880", "Hangup5-Outhouse-Lucrative")

    if signinResponse.isOk:
        echo "Signed in with token: ", signinResponse.ok
    else:
        echo "Signin error: ", signinResponse.error
        quit(1)

    let createResponse = await surreal.create(rc"testitem:12345", {"name": "Ben", "state": "sleepy"})
    if createResponse.isOk:
        echo "Create response: ", createResponse.ok
    else:
        echo "Create error: ", createResponse.error
        quit(1)

    let selectResponse = await surreal.select(rc"testitem:12345")
    if selectResponse.isOk:
        echo "Select response: ", selectResponse.ok
    else:
        echo "Select error: ", selectResponse.error
        quit(1)



    # var futures: seq[Future[SurrealResult[JsonNode]]] = @[]
    # for i in 0..<20:
    #     futures.add(surreal.select("item"))

    # let responses = await futures.all()

    # echo "Received ", responses.len, " responses"

    # for response in responses:
    #     let itemsCount = response.ok.getElems().len()
    #     if itemsCount != 1000:
    #         echo "Didn't receive 1000 items in one of the responses..."

    surreal.disconnect()

waitFor main()