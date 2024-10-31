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

    try:
      let queryRes = await surreal.query(surql"""RETURN [(SELECT * FROM testproduct), (SELECT * FROM testproduct2)]""")
      if queryRes.isOk:
          # echo "Query response: ", queryRes.ok.getSeq[0]["result"].debugPrintSurrealValue
          #echo "Query response: ", queryRes.ok.getSeq[0]["result"]
          echo "Received total of ", queryRes.ok.getSeq[0]["result"].getSeq[0].len + queryRes.ok.getSeq[0]["result"].getSeq[1].len
      else:
          echo "Query error: ", queryRes.error
          quit(1)
    except CatchableError as e:
        echo "Error: ", e.msg

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
