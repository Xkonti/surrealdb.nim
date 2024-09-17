type
    Result*[T, E] = object
        case isOk*: bool
        of true:
            ok*: T
        of false:
            error*: E


proc ok*[T, E](value: T): Result[T, E] =
  Result[T, E](isOk: true, ok: value)

proc err*[T, E](value: E): Result[T, E] =
  Result[T, E](isOk: false, error: value)