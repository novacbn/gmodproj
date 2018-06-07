import ipairs, loadstring, pairs, setmetatable, type from _G
import stderr from io
import format, match, rep from string
import concat, insert from table

import getKeys, getSortedValues, isArray from "novacbn/properties/utilities"

-- LuaEncoder::LuaEncoder()
-- Represents a Lua value visitor for encoding into human-readable Lua
-- export
export LuaEncoder = with {}
    -- LuaEncoder::options -> EncoderOptions
    -- Represents the EncoderOptions configuration struct
    --
    options = nil

    -- LuaEncoder::stackLevel -> number
    -- Represents the current stack level of the Encoder
    --
    .stackLevel = -1

    -- LuaEncoder::new(EncoderOptions encoderOptions) -> Encoder
    -- Makes a new Encoder instance
    --
    .new = (encoderOptions) =>
        return setmetatable({options: encoderOptions}, self)

    -- LuaEncoder::append(any value, boolean ignoreStack, boolean appendTail) -> void
    -- Appends a value to the current string buffer
    --
    .append = (value, ignoreStack, appendTail) =>
        if ignoreStack or @stackLevel < 1
            unless appendTail then insert(self, value)
            else
                length      = #self
                @[length]   = @[length]..value
            
        else insert(self, rep(@options.indentationChar, @stackLevel)..value)

    -- LuaEncoder::boolean(boolean value) -> string
    -- Encodes a boolean value to the current string buffer
    --
    .boolean = (value) => value and "true" or "false"

    -- LuaEncoder::boolean_key(boolean value) -> string
    -- Encodes a boolean-based key to the current string buffer
    --
    .boolean_key = (value) => "["..(value and "true" or "false").."]"

    -- LuaEncoder::number(number value) -> string
    -- Encodes a number value to the current string buffer
    --
    .number = (value) => tostring(value)

    -- LuaEncoder::number_key(number value) -> string
    -- Encodes a number-based key to the current string buffer
    --
    .number_key = (value) => "["..value.."]"

    -- LuaEncoder::string(string value) -> string
    -- Encodes a string value to the current string buffer
    --
    .string = (value) => format("%q", value)

    -- LuaEncoder::string_key(string value) -> string
    -- Encodes a string-based key to the current string buffer
    --
    .string_key = (value) => match(value, "^%a+$") and value or format("[%q]", value)

    -- LuaEncoder::array(table arr) -> void
    -- Encodes an array-based table to the current string buffer
    --
    .array = (arr) =>
        length = #arr

        local encoder
        for index, value in ipairs(arr)
            encoder = @[type(value)]
            error("bad argument #1 to 'Encoder.array' (unexpected type)") unless encoder

            -- Append comma delimiter to non-last values
            if encoder == @table then @encoder(self, value, index < length)
            else
                if index < length then @append(encoder(self, value, true)..",")
                else @append(encoder(self, value, false))

    -- LuaEncoder::map(table map) -> void
    -- Encodes a hashmap-based table to the current string buffer
    --
    .map = (map) =>
        -- Sort and count the keys within the map
        keys    = getSortedValues(getKeys(map))
        length  = #keys
        count   = 0

        local keyEncoder, value, valueEncoder
        for key in *keys
            keyEncoder = @[type(key).."_key"]
            error("bad argument #1 to 'Encoder.map' (unexpected key type)") unless keyEncoder

            value           = map[key]
            valueEncoder    = @[type(value)]
            error("bad argument #1 to Encoder.map (unexpected value type)") unless valueEncoder

            -- Append comma delimiter on non-last keypairs
            count += 1
            if valueEncoder == @table
                @append(keyEncoder(self, key).." = ")
                valueEncoder(self, value, count < length)

            else
                if count < length then @append(keyEncoder(self, key).." = "..valueEncoder(self, value)..",")
                else @append(keyEncoder(self, key).." = "..valueEncoder(self, value))

    -- LuaEncoder::table(table tbl, boolean innerMember, boolean isRoot)
    -- Encodes a Lua table to the current string buffer
    --
    .table = (tbl, innerMember, isRoot) =>
        @append("{", true, true) unless isRoot
        @stackLevel += 1

        if isArray(tbl) then @array(tbl)
        else @map(tbl)

        @stackLevel -= 1
        @append(innerMember and "}," or "}") unless isRoot

    -- LuaEncoder::toString() -> string
    -- Converts the current memory buffer into a newline-delimited Lua code string
    --
    .toString = () =>
        return concat(self, "\n")
LuaEncoder.__index = LuaEncoder

-- ::encode(table tbl, EncoderOptions encoderOptions) -> string
-- Encode a Lua table into a human-readable Lua properties format
-- export
export encode = (tbl, encoderOptions) ->
    encoder = LuaEncoder\new(encoderOptions)
    encoder\table(tbl, false, true)

    return encoder\toString()

-- ::decode(string value, DecoderOptions decoderOptions) -> table
-- Decodes a human-readable Lua properties into a Lua table
-- export
export decode = (value, decoderOptions) ->
    error("bad option 'allowUnsafe' to 'decode' (Lua AST parser not implemented)") unless decoderOptions.allowUnsafe

    chunk, err = loadstring("return {#{value}}")
    if err
        stderr\write("bad argument #1 to 'decode' (Lua syntax error)\n")
        error(err)

    return chunk()