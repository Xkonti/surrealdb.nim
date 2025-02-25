import std/[asyncdispatch, tables, strutils, uri]
import ws

import ../types/[surrealdb, surrealResult]
import listenLoop

proc newSurrealDbConnection*(url: string): Future[SurrealDB] {.async.} =
    ## Creates a new SurrealDB connection object.
    ## It establishes a WebSocket connection to the SurrealDB server and starts listening for responses.

    # Verify that the URL is valid and adjust it if necessary
    var address = parseUri(url)
    if address.scheme notin ["ws", "wss"]:
        raise newException(ValueError, "Invalid scheme: " & address.scheme)
    if not address.path.endsWith("rpc"):
        address = address / "rpc"

    # Establish the WebSocket connection
    let ws = await newWebSocket($address, "cbor")

    # Setup the pings
    ws.setupPings(15)

    # Create the SurrealDB object
    let surreal = SurrealDB(
        ws: ws,
        queryFutures: newTable[string, FutureResponse](),
        isConnected: true
    )
    echo "Connected!"

    # Start loop that listens for responses from the database
    asyncCheck surreal.startListenLoop()

    return surreal


proc disconnect*(db: SurrealDB) =
    ## Disconnects the SurrealDB connection.
    ## It closes the WebSocket connection and invalidates all pending futures.

    db.isConnected = false
    db.ws.close()