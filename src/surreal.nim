# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import std/[asyncdispatch, asyncfutures, json, sequtils, strutils, tables]
import ws

import ./surreal/[core, queries]



proc main() {.async.} =
  # let ws = await newAsyncWebsocketClient("jabba.lan", Port(14831),
  #   path = "/rpc", protocols = @["cbor"])   protocol = "alpha"
  # echo "connected!"
  let ws = await newWebSocket("ws://jabba.lan:14831/rpc")
  ws.setupPings(15)
  let surreal = ws.newSurrealDB()
  echo "connected!"

  # Start loop that listens for responses from the database
  asyncCheck surreal.startListenLoop()

  let ns = "test"
  let db = "test"
  await surreal.use(ns, db)
  echo "Switched to namespace '", ns, "' and database '", db, "'"

  const signInMsg = """{
    "id":-1,
    "method": "signin",
    "params": [
        {
            "user": "disjoin4880",
            "pass": "Hangup5-Outhouse-Lucrative"
        }
    ]
  }"""

  var resp = await surreal.sendQuery(signInMsg)
  echo "Received response: ", resp

  const selectMsg = """{
    "id":-1,
    "method": "select",
    "params": [ "item" ]
  }"""

  var futures: seq[Future[JsonNode]] = @[]
  for i in 0..<50:
    futures.add(surreal.sendQuery(selectMsg))

  let responses = await futures.all()

  echo "Received ", responses.len, " responses"

  ws.close()

waitFor main()