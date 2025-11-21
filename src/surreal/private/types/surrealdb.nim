import std/[tables]
import connection

import surrealResult

type
    SurrealDB* = ref object
        ## The SurrealDB connection object. It handles the connection and gives access to the query methods.
        connection*: SurrealConnection
