var nextId = 0

proc getNextId*(): int =
  inc(nextId)
  return nextId