
--
-- lua-LIVR : <http://fperrad.github.com/lua-LIVR/>
--

local _, pcre = pcall(require, 'rex_pcre')
if _VERSION < 'Lua 5.3' then
    pcall(require, 'compat53')
end
local utf8 = utf8
if not utf8 then
    _, utf8 = pcall(require, 'lua-utf8')
end
local len = utf8 and utf8.len or string.len
local tostring = tostring
local type = type
local _ENV = nil

return {
    one_of = function (_, allowed_values, ...)
        if type(allowed_values) ~= 'table' then
            allowed_values = { allowed_values, ... }
        end
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'string' and type(value) ~= 'number' and type(value) ~= 'boolean' then
                    return value, 'FORMAT_ERROR'
                end
                for i = 1, #allowed_values do
                    local allowed_value = allowed_values[i]
                    if tostring(value) == tostring(allowed_value) then
                        return allowed_value
                    end
                end
                return value, 'NOT_ALLOWED_VALUE'
            end
            return value
        end
    end,

    max_length = function (_, max_length)
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) == 'number' then
                    value = tostring(value)
                end
                if type(value) ~= 'string' then
                    return value, 'FORMAT_ERROR'
                end
                if len(value) > max_length then
                    return value, 'TOO_LONG'
                end
            end
            return value
        end
    end,

    min_length = function (_, min_length)
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) == 'number' then
                    value = tostring(value)
                end
                if type(value) ~= 'string' then
                    return value, 'FORMAT_ERROR'
                end
                if len(value) < min_length then
                    return value, 'TOO_SHORT'
                end
            end
            return value
        end
    end,

    length_equal = function (_, length)
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) == 'number' then
                    value = tostring(value)
                end
                if type(value) ~= 'string' then
                    return value, 'FORMAT_ERROR'
                end
                if len(value) < length then
                    return value, 'TOO_SHORT'
                end
                if len(value) > length then
                    return value, 'TOO_LONG'
                end
            end
            return value
        end
    end,

    length_between = function (_, min_length, max_length)
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) == 'number' then
                    value = tostring(value)
                end
                if type(value) ~= 'string' then
                    return value, 'FORMAT_ERROR'
                end
                if len(value) < min_length then
                    return value, 'TOO_SHORT'
                end
                if len(value) > max_length then
                    return value, 'TOO_LONG'
                end
            end
            return value
        end
    end,

    like_lua = function (_, re)
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) == 'number' then
                    value = tostring(value)
                end
                if type(value) ~= 'string' then
                    return value, 'FORMAT_ERROR'
                end
                if not value:match(re) then
                    return value, 'WRONG_FORMAT'
                end
            end
            return value
        end
    end,

    like = function (_, re, flags)
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) == 'number' then
                    value = tostring(value)
                end
                if type(value) ~= 'string' then
                    return value, 'FORMAT_ERROR'
                end
                if not pcre.match(value, re, 1, flags) then
                    return value, 'WRONG_FORMAT'
                end
            end
            return value
        end
    end,

    string = function ()
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) == 'number' or type(value) == 'boolean' then
                    value = tostring(value)
                end
                if type(value) ~= 'string' then
                    return value, 'FORMAT_ERROR'
                end
            end
            return value
        end
    end,

    equal = function (_, allowed_value)
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'string' and type(value) ~= 'number' and type(value) ~= 'boolean' then
                    return value, 'FORMAT_ERROR'
                end
                if tostring(value) ~= tostring(allowed_value) then
                    return value, 'NOT_ALLOWED_VALUE'
                end
                return allowed_value
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
