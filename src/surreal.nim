# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

# import asyncdispatch, pkg/websocket
import std/strutils
import asyncdispatch, ws

proc receiveResponse(ws: WebSocket, id: int): Future[string] {.async.} =
  let idStr = """"id":""" & $id & ","
  while true:
    var resp = await ws.receivePacket()
    if resp[0] == Opcode.Text and resp[1].contains(idStr):
      return resp[1]

proc main() {.async.} =
  # let ws = await newAsyncWebsocketClient("jabba.lan", Port(14831),
  #   path = "/rpc", protocols = @["cbor"])   protocol = "alpha"
  # echo "connected!"
  let ws = await newWebSocket("ws://jabba.lan:14831/rpc")
  ws.setupPings(15)
  echo "connected!"

  const useMsg = """{
    "id": 1,
    "method": "use",
    "params": [ "test", "test" ]
  }"""
  
  await ws.send(useMsg)
  echo "Sent `use` message"

  var resp = await ws.receiveResponse(1)
  echo "Received response: ", resp

  const signInMsg = """{
    "id": 2,
    "method": "signin",
    "params": [
        {
            "user": "Username",
            "pass": "SecretPassword"
        }
    ]
  }"""

  await ws.send(signInMsg)
  echo "Sent `signin` message"
  resp = await ws.receiveResponse(2)
  echo "Received response: ", resp

  const selectMsg = """{
    "id": 3,
    "method": "select",
    "params": [ "item" ]
  }"""

  await ws.send(selectMsg)
  echo "Sent `select` message"
  resp = await ws.receiveResponse(3)
  echo "Received response: ", resp

  ws.close()

waitFor main()