import std/[asyncdispatch, json, tables, strutils]
import ws

import ../types/[surrealdb, surrealResult]

proc startListenLoop*(db: SurrealDB) {.async.} =
    ## Initializes a loop that listens for WebSocket messagges.
    ## It matches received messages with the futures for sent queries and
    ## completes the futures with response contents.
    echo "Starting listen loop"
    while db.isConnected:
        # Receive a message from the WebSocket
        var resp = await db.ws.receivePacket()
        if resp[0] != Opcode.Text:
            # Ignore non-text messages
            continue

        # Parse the message as JSON
        let jsonObject = parseJson(resp[1])

        # If no ID is present, we can't match it to a request future.
        # Most likely the request was malformed and the server couldn't extract the ID from it.
        if not jsonObject.hasKey("id"):
            echo "Malformed request received: ", jsonObject
            continue

        # Extract the ID of the request and locate the future
        let queryId: int = jsonObject["id"].getInt()
        echo "Response for query ID: ", queryId

        # If counldn't find the future, we can't complete it, move on
        if not db.queryFutures.hasKey(queryId):
            echo "No future found for query ID: ", queryId
            continue

        # Remove the future from the table - consider it handled
        let future = db.queryFutures[queryId]
        db.queryFutures.del(queryId)

        # If it's an error message, complete the future with the error
        if jsonObject.hasKey("error"):
            future.complete(surrealError(
                jsonObject["error"]["code"].getInt(),
                jsonObject["error"]["message"].getStr()))
        # Otherwise, complete the future with the response content
        else:
            future.complete(surrealResponseJson(jsonObject["result"]))