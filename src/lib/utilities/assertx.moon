import error from _G

-- ::argument(any conditional, number argument, string name, string tag, number stackLevel?) -> any
-- Performs a Lua-style assert e.g. 'bad argument #? to '?' (?)'
export argument = (conditional, argument, name, tag, stackLevel=2) ->
    -- If the conditional is truthy, return it, otherwise perform formatted error
    return conditional if conditional
    error("bad argument ##{argument} to '#{name}' (#{tag})", stackLevel)