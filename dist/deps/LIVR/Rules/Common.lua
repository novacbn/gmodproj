
--
-- lua-LIVR : <http://fperrad.github.com/lua-LIVR/>
--

local type = type
local _ENV = nil

return {
    required = function ()
        return function (value)
            if value ~= nil and value ~= '' then
                return value
            end
            return value, 'REQUIRED'
        end
    end,

    not_empty = function ()
        return function (value)
            if value ~= '' then
                return value
            end
            return value, 'CANNOT_BE_EMPTY'
        end
    end,

    not_empty_list = function ()
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'table' then
                    return value, 'FORMAT_ERROR'
                end
                if #value ~= 0 then
                    return value
                end
            end
            return value, 'CANNOT_BE_EMPTY'
        end
    end,

    any_object = function ()
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'table' or #value ~= 0 then
                    return value, 'FORMAT_ERROR'
                end
            end
            return value
        end
    end,
}

--
-- Copyright (c) 2018 Francois Perrad
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
