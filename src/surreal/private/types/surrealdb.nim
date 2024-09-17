import std/[tables]
import ws

import surrealResult

type
    SurrealDB* = ref object
        ## The SurrealDB connection object. It handles the WebSocket connection and gives access to the query methods.

        ws*: WebSocket
        # TODO: Add a timeout for each future in case the response is not received / can't be linked to the request
        queryFutures*: TableRef[int, FutureResponse]
        isConnected*: bool