import select, unpack from _G

-- ::bind(function boundFunction, any ...) -> function
-- Returns a new function that calls the bound function with the specified arguments
-- export
export bind = (boundFunction, ...) ->
    varArgs = pack(...)
    return (...) ->
        boundFunction(unpack(varArgs), ...)

-- ::pack(any ...) -> table
-- Returns a table that packs varargs in a nil value respecting structure
-- export
export pack = (...) ->
    return {n: select("#", ...), ...}