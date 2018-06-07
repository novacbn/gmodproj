import
    getmetatable, ipairs, pairs, setfenv,
    setmetatable, tostring
from _G
import gsub, match, rep from string
import concat, insert from table

import loadstring from require "moonscript/base"

import isNumericTable, isSequentialTable from "novacbn/novautils/table"

import deprecate from "novacbn/gmodproj/lib/utilities/deprecate"
import makeStringEscape from "novacbn/gmodproj/lib/utilities/string"

-- ::escapeString(string unescapedString) -> string
-- Escapes a string to be Lua-safe
escapeString = makeStringEscape {
    {"\\", "\\\\"},
    {"'", "\\'"},
    {"\t", "\\t"},
    {"\n", "\\n"},
    {"\r", "\\r"}
}

-- ::encodeKeyString(string stringKey) -> string, boolean
-- Encodes a string-key for DataFile serialization
encodeKeyString = (stringKey) ->
    -- Escape the string before encoding
    stringKey = escapeString(stringKey)

    -- If the key starts with a letter, encode as a function call, otherwise encode as a table key
    if match(stringKey, "^%a") then return stringKey, false
    return "'#{stringKey}'", true

-- ::encodeValueString(string stringValue) -> string
-- Encodes a string-value for DataFile serialization
encodeValueString = (stringValue) ->
    -- Escape the string before encoding, then encode as Lua string
    stringValue = escapeString(stringValue)
    return "'#{stringValue}'"

-- ::encodeValueTable(table tableValue, number stackLevel?) -> string
-- Encodes a table-value for DataFile serialization
local encodeKey, encodeValue
encodeValueTable = (tableValue, stackLevel=0) ->
    -- Make the new string stack and calculate the tabs per member
    stringStack = {}
    stackTabs   = rep("\t", stackLevel)

    -- If this is a nested table, add a opening bracket
    insert(stringStack, "{") if stackLevel > 0

    -- Check if the table is a sequential numeric table or a map
    if isNumericTable(tableValue) and isSequentialTable(tableValue)
        -- Loop through the sequential table and serialize each value, ignoring the indexes
        local encodedValue
        tableLength = #tableValue
        for index, value in ipairs(tableValue)
            -- Encode the value before adding to the stack
            encodedValue = encodeValue(value, stackLevel + 1)

            -- If this isn't the last table value, append a comma seperator to the value
            if index < tableLength then insert(stringStack, stackTabs..encodedValue..",")
            else insert(stringStack, stackTabs..encodedValue)

    else
        local keyType, encodedKey, keyEncapsulate, valueType, encodedValue
        for key, value in pairs(tableValue)
            -- Encode the keys and values before adding to the stack
            encodedKey, keyEncapsulate  = encodeKey(key)
            encodedValue                = encodeValue(value, stackLevel + 1)

            -- If it is an encapsulated key, add boundry brackets to the key
            if keyEncapsulate then insert(stringStack, stackTabs.."[#{encodedKey}]: #{encodedValue}")
            else insert(stringStack, stackTabs.."#{encodedKey} #{encodedValue}")

    -- If this is a nested table, add a closing bracket, then return the serialized table
    insert(stringStack, rep("\t", stackLevel - 1).."}") if stackLevel > 0
    return concat(stringStack, "\n")

-- ::typeEncodeMap -> table
-- Represents a map of key and value type encoders
typeEncodeMap = {
    key: {
        boolean:    => @, true,
        number:     => @, true,
        string:     encodeKeyString
    },

    value: {
        boolean:    tostring
        number:     => @
        string:     encodeValueString,
        table:      encodeValueTable
    }
}

-- ::encodeKey(any key, any ...) -> string
-- Encodes a key to the DataFile format
encodeKey = (key, ...) ->
    -- Validate that the key can be encoded, then encode it
    keyEncoder = typeEncodeMap.key[type(key)]
    error("cannot encode key '#{key}', unsupported type") unless keyEncoder
    return keyEncoder(key, ...)

-- ::encodeValue(any value, any ...) -> string
-- Encodes a value to the DataFile format
encodeValue = (value, ...) ->
    -- Validate the the value can be encoded, then encode it
    valueEncoder = typeEncodeMap.value[type(value)]
    error("cannot encode value '#{value}', unsupported type") unless valueEncoder
    return valueEncoder(value, ...)

-- ::KeyPair(string name, function levelToggle) -> KeyPair
-- A primitive type representing a DataFile key value
KeyPair = (name, levelToggle) -> setmetatable({:name}, {
    __call: (value) =>
        if type(value) == "table"
            removedKeys = {}
            for key, subValue in pairs(value)
                if type(subValue) == "table" and getmetatable(subValue)
                    value[subValue.name]    = subValue.value if subValue.value ~= nil
                    insert(removedKeys, key)

            value[key] = nil for key in *removedKeys

        @value = value
        levelToggle(name, value) if levelToggle
        return self
})

-- ::ChunkEnvironment(table dataExports) -> ChunkEnvironment, table
-- A primitive type representing a DataFile Lua environment
ChunkEnvironment = (dataExports={}) ->
    -- Create a flag for if the next member if top-level
    topLevel    = true
    levelToggle = (key, value) ->
        -- Assign the data export and reset the flag
        dataExports[key]    = value
        topLevel            = true

    return setmetatable({}, {
        __index: (key) =>
            -- Make a new KeyPair with the levelToggle if it's a top-level member
            keyPair     = KeyPair(key, topLevel and levelToggle)
            topLevel    = false
            return keyPair
    }), dataExports

-- ::loadChunk(function sourceChunk) -> table
-- Parses a function chunk as a DataFile
-- export
export loadChunk = (sourceChunk) ->
    deprecate("novacbn/gmodproj/lib/datafile::loadChunk", "novacbn/gmodproj/lib/datafile::loadChunk is deprecated, see 0.4.0 changelog")

    -- Make the new environment for the chunk then run and return exports
    chunkEnvironment, dataExports = ChunkEnvironment()
    setfenv(sourceChunk, chunkEnvironment)()
    return dataExports

-- ::readString(string sourceString, string chunkName?) -> table
-- Deserializes a table in the DataFile format
-- TODO:
--  add flag to perform lexical parsing instead of loading code for safer deserialization
-- export
export fromString = (sourceString, chunkName="DataFile Chunk") ->
    deprecate("novacbn/gmodproj/lib/datafile::fromString", "novacbn/gmodproj/lib/datafile::fromString is deprecated, see 0.4.0 changelog")

    -- Parse the string with MoonScript then load it as a function chunk
    sourceChunk = loadstring(sourceString, chunkName)
    return loadChunk(sourceChunk)

-- ::toString(table sourceTable) -> string
-- Serializes a table into the DataFile format
-- TODO:
--  support alphabetic and values before tables sortings
-- export
export toString = (sourceTable) ->
    deprecate("novacbn/gmodproj/lib/datafile::toString", "novacbn/gmodproj/lib/datafile::toString is deprecated, see 0.4.0 changelog")

    -- Validate the table then serialize it
    error("only table values can be serialized") unless type(sourceTable) == "table"
    return typeEncodeMap.value.table(sourceTable, 0)

