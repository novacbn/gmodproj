
--
-- lua-LIVR : <http://fperrad.github.com/lua-LIVR/>
--

local tointeger
if _VERSION >= 'Lua 5.3' then
    tointeger = math.tointeger
else
    local SIZEOF_NUMBER = 8
    if not jit then
        -- Lua 5.1 & 5.2
        local loadstring = loadstring or load
        local luac = string.dump(loadstring "a = 1")
        local header = { luac:sub(1, 12):byte(1, 12) }
        SIZEOF_NUMBER = header[11]
    end
    local maxinteger = (SIZEOF_NUMBER == 4) and 16777215 or 9007199254740991
    local mininteger = -maxinteger
    local floor = math.floor
    tointeger = function (v)
        -- Lua 5.1, 5.2 & LuaJIT
        local n = tonumber(v)
        if n and floor(n) == n and n < maxinteger and n > mininteger then
            return n
        end
    end
end

local tonumber = tonumber
local type = type
local _ENV = nil

return {
    integer = function ()
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'string' and type(value) ~= 'number' then
                    return value, 'FORMAT_ERROR'
                end
                local num = tointeger(value)
                if num == nil then
                    return value, 'NOT_INTEGER'
                end
                value = num
            end
            return value
        end
    end,

    positive_integer = function ()
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'string' and type(value) ~= 'number' then
                    return value, 'FORMAT_ERROR'
                end
                local num = tointeger(value)
                if num == nil or num <= 0 then
                    return value, 'NOT_POSITIVE_INTEGER'
                end
                value = num
            end
            return value
        end
    end,

    decimal = function ()
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'string' and type(value) ~= 'number' then
                    return value, 'FORMAT_ERROR'
                end
                local num = tonumber(value)
                if num == nil then
                    return value, 'NOT_DECIMAL'
                end
                value = num
            end
            return value
        end
    end,

    positive_decimal = function ()
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'string' and type(value) ~= 'number' then
                    return value, 'FORMAT_ERROR'
                end
                local num = tonumber(value)
                if num == nil or num <= 0 then
                    return value, 'NOT_POSITIVE_DECIMAL'
                end
                value = num
            end
            return value
        end
    end,

    max_number = function (_, max_number)
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'string' and type(value) ~= 'number' then
                    return value, 'FORMAT_ERROR'
                end
                local num = tonumber(value)
                if num == nil then
                    return value, 'NOT_NUMBER'
                end
                if num > max_number then
                    return value, 'TOO_HIGH'
                end
                value = num
            end
            return value
        end
    end,

    min_number = function (_, min_number)
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'string' and type(value) ~= 'number' then
                    return value, 'FORMAT_ERROR'
                end
                local num = tonumber(value)
                if num == nil then
                    return value, 'NOT_NUMBER'
                end
                if num < min_number then
                    return value, 'TOO_LOW'
                end
                value = num
            end
            return value
        end
    end,

    number_between = function (_, min_number, max_number)
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'string' and type(value) ~= 'number' then
                    return value, 'FORMAT_ERROR'
                end
                local num = tonumber(value)
                if num == nil then
                    return value, 'NOT_NUMBER'
                end
                if num < min_number then
                    return value, 'TOO_LOW'
                end
                if num > max_number then
                    return value, 'TOO_HIGH'
                end
                value = num
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
