type
    Result*[T, E] = object
        ## A generic result type that can either be successful or contain an error.
        case isOk*: bool
        of true:
            ok*: T
        of false:
            error*: E


proc ok*[T, E](value: T): Result[T, E] =
    ## Creates a new successful result with the specified value.
    Result[T, E](isOk: true, ok: value)

proc err*[T, E](value: E): Result[T, E] =
    ## Creates a new error result with the specified value.
    Result[T, E](isOk: false, error: value)