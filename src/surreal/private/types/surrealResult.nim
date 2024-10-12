import std/[asyncdispatch, json]
import surrealValue
import result

type
    SurrealError* = object
        ## An common error object returned by the SurrealDB server.
        code*: int
        message*: string

    SurrealResult*[T] = Result[T, SurrealError]
        ## A SurrealDB result type that can either be successful or contain an error.

    FutureResponse* = Future[SurrealResult[SurrealValue]]


proc surrealError*(code: int, message: string): SurrealResult[SurrealValue] =
    ## Create a new error result with the specified error code and message.
    err[SurrealValue, SurrealError](SurrealError(code: code, message: message))

proc surrealResponseValue*(value: SurrealValue): SurrealResult[SurrealValue] =
    ## Creates a new successful result with the specified JSON value.
    ok[SurrealValue, SurrealError](value)

proc surrealResponse*[T](value: T): SurrealResult[T] =
    ## Creates a new successful result with the specified value.
    ok[T, SurrealError](value)

proc asError*[TInput, TOutput](response: SurrealResult[TInput]): SurrealResult[TOutput] =
    ## Helps in converting error result of one type to another.
    if response.isOk:
        raise newException(ValueError, "Cannot convert a successful response to an error")

    err[TOutput, SurrealError](response.error)