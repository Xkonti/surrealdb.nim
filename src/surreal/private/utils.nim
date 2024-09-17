var nextId = 0

proc getNextId*(): int =
    ## Generates a new ID for a request.

    inc(nextId)
    return nextId