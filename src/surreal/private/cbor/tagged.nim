type
    Tagged*[T] = ref object
        tag: uint64 # For some values could be less, but might be better to just leave it as uint64
        value: T

proc newTagged*[T](tag: uint64, value: T): Tagged[T] =
    ## Creates a new Tagged instance.
    return Tagged[T](tag: tag, value: value)

proc tag*[T](tagged: Tagged[T]): uint64 =
    ## Returns the tag of the Tagged instance.
    return tagged.tag

proc value*[T](tagged: Tagged[T]): T =
    ## Returns the value of the Tagged instance.
    return tagged.value