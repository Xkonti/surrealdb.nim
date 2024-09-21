type
    Gap*[T] = ref object
        ## A Gap represents a placeholder in partially encoded CBOR data.
        ## It can optionally hold a default value.
        ## A Gap has a default value if it was created with exactly one argument.
        args: seq[T]

    Fill*[T] = tuple[gap: Gap[T], value: T]
        ## A Fill is used to provide a value for a Gap when finalizing partially encoded CBOR data.

proc newGap*[T](args: varargs[T]): Gap[T] =
    ## Creates a new Gap instance.
    return Gap[T](args: args)

proc fill[T](gap: Gap[T], value: T): Fill[T] =
    ## Creates a Fill from a Gap and a value.
    return Fill[T](gap: gap, value: value)

proc hasDefault*[T](gap: Gap[T]): bool =
    ## Checks if the Gap has a default value.
    ## A Gap has a default value if it was created with exactly one argument.
    return gap.args.len == 1

proc default*[T](gap: Gap[T]): T =
    ## Returns the default value of the Gap.
    ## Should only be called if hasDefault() returns true.
    return gap.args[0]