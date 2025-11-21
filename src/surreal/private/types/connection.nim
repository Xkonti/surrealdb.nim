import std/[asyncdispatch]
import ../types/[surrealResult, surrealValue]

type
    SurrealConnection* = ref object of RootObj
        ## Abstract base class for SurrealDB connections.

method connect*(this: SurrealConnection, url: string): Future[void] {.base, async.} =
    ## Connects to the SurrealDB server.
    raise newException(Defect, "Method connect not implemented")

method disconnect*(this: SurrealConnection) {.base.} =
    ## Disconnects from the SurrealDB server.
    raise newException(Defect, "Method disconnect not implemented")

method send*(this: SurrealConnection, methodStr: string, params: seq[SurrealValue]): Future[SurrealResult[SurrealValue]] {.base, async.} =
    ## Sends a request to the SurrealDB server.
    raise newException(Defect, "Method send not implemented")
