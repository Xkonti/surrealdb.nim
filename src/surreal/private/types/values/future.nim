proc newFutureWrapper*(inner: SurrealValue): SurrealValue =
    ## Wraps the provided SurrealValue into a SurrealFuture
    return SurrealValue(kind: SurrealFuture, futureVal: inner)

proc unwrap*(future: SurrealValue): SurrealValue =
    # Exrtracts the inner value from the SurrealObject (future)
    case future.kind
    of SurrealFuture:
        return future.futureVal
    else:
        raise newException(ValueError, "Cannot extract an intter value from a $ value" % $future.kind)

proc unwrapFuture*(future: SurrealValue): SurrealValue =
    # Exrtracts the inner value from the SurrealObject (future)
    return future.unwrap()
