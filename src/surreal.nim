# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import std/[asyncdispatch, asyncfutures, json, sequtils, strutils, tables]
import ws

var nextId = 0

proc getNextId(): int =
  inc(nextId)
  return nextId

var queryFutures = newTable[int, Future[JsonNode]]()


proc startListenLoop(ws: WebSocket) {.async.} =
  echo "Starting listen loop"
  while true:
    var resp = await ws.receivePacket()
    if resp[0] != Opcode.Text:
      continue
    let jsonObject = parseJson(resp[1])
    let queryId: int = jsonObject["id"].getInt()
    echo "Reqponse for query ID: ", queryId
    if queryFutures.hasKey(queryId):
      let future = queryFutures[queryId]
      queryFutures.del(queryId)
      future.complete(jsonObject)


proc sendQuery(ws: WebSocket, query: string): Future[JsonNode] {.async.} =
  let queryId = getNextId()
  echo "Sending query with ID: ", queryId
  let future: Future[JsonNode] = newFuture[JsonNode]("sendQuery #" & $queryId)

  try:
    let queryWithId = query.replace("\"id\":-1", "\"id\":" & $queryId)
    await ws.send(queryWithId)
    queryFutures[queryId] = future
  except CatchableError as e:
    echo "Error sending query: ", e.msg
    future.fail(e)
  finally:
    return await future


proc main() {.async.} =
  # let ws = await newAsyncWebsocketClient("jabba.lan", Port(14831),
  #   path = "/rpc", protocols = @["cbor"])   protocol = "alpha"
  # echo "connected!"
  let ws = await newWebSocket("ws://jabba.lan:14831/rpc")
  ws.setupPings(15)
  echo "connected!"

  # Start loop that listens for responses from the database
  asyncCheck startListenLoop(ws)

  const useMsg = """{
    "id":-1,
    "method": "use",
    "params": [ "test", "test" ]
  }"""
  
  var resp = await ws.sendQuery(useMsg)
  echo "Received response: ", resp

  const signInMsg = """{
    "id":-1,
    "method": "signin",
    "params": [
        {
            "user": "Username",
            "pass": "SecretPassword"
        }
    ]
  }"""

  resp = await ws.sendQuery(signInMsg)
  echo "Received response: ", resp

  const selectMsg = """{
    "id":-1,
    "method": "select",
    "params": [ "item" ]
  }"""

  var futures: seq[Future[JsonNode]] = @[]
  for i in 0..<50:
    futures.add(ws.sendQuery(selectMsg))

  let responses = await futures.all()

  echo "Received ", responses.len, " responses"

  ws.close()

waitFor main()