
--
-- lua-LIVR : <http://fperrad.github.com/lua-LIVR/>
--
local _, utf8 = pcall(require, 'lua-utf8')
local lower = utf8 and utf8.lower or string.lower
local upper = utf8 and utf8.upper or string.upper
local tostring = tostring
local type = type
local _ENV = nil

return {
    trim = function ()
        return function (value)
            if type(value) == 'number' or type(value) == 'boolean' then
                value = tostring(value)
            end
            if type(value) == 'string' then
                value = value:gsub('^%s+', '')
                value = value:gsub('%s+$', '')
            end
            return value
        end
    end,

    to_lc = function ()
        return function (value)
            if type(value) == 'number' or type(value) == 'boolean' then
                value = tostring(value)
            end
            if type(value) == 'string' then
                value = lower(value)
            end
            return value
        end
    end,

    to_uc = function ()
        return function (value)
            if type(value) == 'number' or type(value) == 'boolean' then
                value = tostring(value)
            end
            if type(value) == 'string' then
                value = upper(value)
            end
            return value
        end
    end,

    remove = function (_, chars)
        local re = '[' .. chars:gsub('[%%%-%]%[%^]', '%%%1') .. ']'
        return function (value)
            if type(value) == 'number' then
                value = tostring(value)
            end
            if type(value) == 'string' then
                value = value:gsub(re, '')
            end
            return value
        end
    end,

    leave_only = function (_, chars)
        local re = '[^' .. chars:gsub('[%%%-%]%[]', '%%%1') .. ']'
        return function (value)
            if type(value) == 'number' then
                value = tostring(value)
            end
            if type(value) == 'string' then
                value = value:gsub(re, '')
            end
            return value
        end
    end,

    default = function (_, default_value)
        return function (value)
            if value == nil or value == '' then
                value = default_value or {}
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
