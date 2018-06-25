-- ::makeAdaptedSync(function func) -> function
-- Adapts a libuv function to dispatch errors
-- export
export makeAdaptedSync = (func) ->
    return (...) ->
        results, err = func(...)
        error(err) if err
        return results