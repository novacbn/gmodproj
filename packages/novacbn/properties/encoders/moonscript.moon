import pairs, setmetatable, type from _G
import stderr from io
import format, match, rep from string
import insert from table

hasMoonScript, moonscript = pcall(require, "moonscript/base")

import getKeys, getSortedValues, isArray from "novacbn/properties/utilities"
import LuaEncoder from "novacbn/properties/encoders/lua"

-- MoonScriptEncoder::MoonScriptEncoder()
-- Represents a Lua value visitor for encoding into human-readable MoonScript
-- export
export MoonScriptEncoder = with {}
    -- MoonScriptEncoder::new(EncoderOptions encoderOptions) -> Encoder
    -- Makes a new Encoder instance
    --
    .new = (encoderOptions) =>
        return setmetatable({options: encoderOptions}, self)

    -- MoonScriptEncoder::boolean_key(boolean value) -> string
    -- Encodes a boolean-based key to the current string buffer
    --
    .boolean_key = (value) => value and "true" or "false"

    -- MoonScriptEncoder::string_key(string value) -> string
    -- Encodes a string-based key to the current string buffer
    --
    .string_key = (value) => match(value, "^%a+$") and value or format("%q", value)

    -- MoonScriptEncoder::map(table map) -> void
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
                @append(keyEncoder(self, key)..": ")
                valueEncoder(self, value, count < length)

            else @append(keyEncoder(self, key)..": "..valueEncoder(self, value))

    -- MoonScriptEncoder::table(table tbl, boolean innerMember, boolean isRoot)
    -- Converts the current memory buffer into a newline-delimited Lua code string
    --
    .table = (tbl, innerMember, isRoot) =>
        @stackLevel += 1

        if isArray(tbl) then
            @append("{", true, true) unless isRoot
            @array(tbl)
            @stackLevel -= 1
            @append("}") unless isRoot

        else
            @map(tbl)
            @stackLevel -= 1

setmetatable(MoonScriptEncoder, LuaEncoder)
MoonScriptEncoder.__index = MoonScriptEncoder

-- ::encode(table tbl, EncoderOptions encoderOptions) -> string
-- Encode a Lua table into a human-readable MoonScript properties format
-- export
export encode = (tbl, encoderOptions) ->
    encoder = MoonScriptEncoder\new(encoderOptions)
    encoder\table(tbl, false, true)

    return encoder\toString()

-- ::decode(string value, DecoderOptions decoderOptions) -> table
-- Decodes a human-readable MoonScript properties into a Lua table
-- export
export decode = (value, decoderOptions) ->
    error("bad dispatch to 'decode' (MoonScript library is not installed)") unless hasMoonScript
    error("bad option 'allowUnsafe' to 'decode' (MoonScript AST parser not implemented)") unless decoderOptions.allowUnsafe

    chunk, err = moonscript.loadstring("{#{value}}")
    if err
        stderr\write("bad argument #1 to 'decode' (MoonScript syntax error)\n")
        error(err)

    return chunk()