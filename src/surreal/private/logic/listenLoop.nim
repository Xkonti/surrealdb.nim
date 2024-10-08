import std/[asyncdispatch, strutils, tables]
import ws

import ../types/[surrealdb, surrealResult, surrealValue]
import ../cbor/[decoder]

proc startListenLoop*(db: SurrealDB) {.async.} =
    ## Initializes a loop that listens for WebSocket messagges.
    ## It matches received messages with the futures for sent queries and
    ## completes the futures with response contents.
    echo "Starting listen loop"
    while db.isConnected:
        # Receive a message from the WebSocket
        let (opcode, message) = await db.ws.receivePacket()
        case opcode
        of Opcode.Text:
            # Parse the message as JSON
            echo "Received message: ", message
        of Opcode.Binary:
            # Parse the message as CBOR
            let data = cast[seq[uint8]](message)
            echo "Received message (raw): ", data
            let decodedMessage = decode(cast[seq[uint8]](message))
            echo "Received message of kind: ", decodedMessage.kind
            echo "Message: ", decodedMessage

            # If no ID is present, we can't match it to a request future.
            # Most likely the request was malformed and the server couldn't extract the ID from it.
            if not decodedMessage.hasKey("id"):
                echo "Malformed request received: ", decodedMessage
                continue

            # Extract the ID of the request and locate the future
            let queryId: string = decodedMessage["id"].getString()
            echo "Response for query ID: ", queryId, " with length of ", queryId.len
            echo "Response for query ID: ", queryId, " with length of ", queryId.len
            echo "Response for query ID: ", queryId, " with length of ", queryId.len

            # If counldn't find the future, we can't complete it, move on
            if not (db.queryFutures.hasKey(queryId)):
                echo "No future found for query ID: ", queryId
                continue

            # Remove the future from the table - consider it handled
            let future = db.queryFutures[queryId]
            db.queryFutures.del(queryId)

            # If it's an error message, complete the future with the error
            if decodedMessage.hasKey("error"):
                future.complete(surrealError(
                    decodedMessage["error"]["code"].toInt32(),
                    decodedMessage["error"]["message"].getString()))

            # Otherwise, complete the future with the response content
            else:
                future.complete(surrealResponseValue(decodedMessage["result"]))
                echo "Returned result: ", decodedMessage["result"]
        else:
            # Ignore non-text and non-binary messages
            continue
