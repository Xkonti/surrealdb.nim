import std/[asyncdispatch, tables, strutils, uri]
import ../types/[surrealdb, connection]
import ../connections/ws_cbor

proc newSurrealDbConnection*(url: string): Future[SurrealDB] {.async.} =
    ## Creates a new SurrealDB connection object.
    ## It establishes a connection to the SurrealDB server and starts listening for responses.

    # Determine connection type based on URL
    var address = parseUri(url)

    var conn: SurrealConnection

    if address.scheme in ["ws", "wss"]:
        conn = WsCborConnection()
    else:
        # Fallback or throw error for unsupported schemes
        # For now, default to WsCbor if it looks like ws/wss or raise error
        raise newException(ValueError, "Unsupported scheme: " & address.scheme)

    await conn.connect(url)

    let surreal = SurrealDB(
        connection: conn
    )
    echo "Connected!"

    return surreal


proc disconnect*(db: SurrealDB) =
    ## Disconnects the SurrealDB connection.
    db.connection.disconnect()
