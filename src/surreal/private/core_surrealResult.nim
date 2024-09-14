type
    SurrealError* = object
        code*: int
        message*: string

    SurrealResult*[T] = Result[T, SurrealError]
    FutureResponse* = Future[SurrealResult[JsonNode]]


proc surrealError(code: int, message: string): SurrealResult[JsonNode] =
    err[JsonNode, SurrealError](SurrealError(code: code, message: message))

proc surrealResponseJson*(value: JsonNode): SurrealResult[JsonNode] =
    ok[JsonNode, SurrealError](value)

proc surrealResponse*[T](value: T): SurrealResult[T] =
    ok[T, SurrealError](value)

proc asError*[TInput, TOutput](response: SurrealResult[TInput]): SurrealResult[TOutput] =
    if response.isOk:
        raise newException(ValueError, "Cannot convert a successful response to an error")
    
    err[TOutput, SurrealError](response.error)