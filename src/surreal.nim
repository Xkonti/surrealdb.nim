import std/[asyncdispatch, asyncfutures, strutils]
import surrealdb

# import surreal/private/cbor/[decoder]

proc main() {.async.} =

    echo "Connecting to SurrealDB..."
    let surreal = await newSurrealDbConnection("ws://jabba.lan:14831/rpc")
    defer: surreal.disconnect()

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

    let selectResponse = await surreal.select(rc"testitem:12345")
    if selectResponse.isOk:
        echo "Select response: ", selectResponse.ok
    else:
        echo "Select error: ", selectResponse.error
        quit(1)

    # var futures: seq[FutureResponse] = @[]
    # for i in 0..<10:
    #     futures.add(surreal.select(tb"item"))

    # let responses = await futures.all()

    # echo "Received ", responses.len, " responses"

    # for response in responses:
    #     echo "Response: (", response.ok.kind , ") of ", response.ok.len, " items"

try:
    waitFor main()
except CatchableError as e:
    echo "Error: ", e.msg
