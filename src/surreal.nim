# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import std/[asyncdispatch, asyncfutures, json, sequtils, strutils, tables]

import ./surreal/[core, queries, useQuery]



proc main() {.async.} =
    # let ws = await newAsyncWebsocketClient("jabba.lan", Port(14831),
    #   path = "/rpc", protocols = @["cbor"])   protocol = "alpha"
    # echo "connected!"

    let surreal = await newSurrealDbConnection("ws://jabba.lan:14831/rpc")

    let ns = "test"
    let db = "test"
    await surreal.use(ns, db)
    echo "Switched to namespace '", ns, "' and database '", db, "'"

    discard await surreal.signin("disjoin4880", "Hangup5-Outhouse-Lucrative")
    echo "Signed in!"

    var futures: seq[Future[JsonNode]] = @[]
    for i in 0..<20:
        futures.add(surreal.select("item"))

    let responses = await futures.all()

    echo "Received ", responses.len, " responses"

    for response in responses:
        let result = response["result"]
        let itemsCount = result.getElems().len()
        if itemsCount != 1000:
            echo "Didn't receive 1000 items in one of the responses..."

    surreal.disconnect()

waitFor main()