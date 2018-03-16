import getmetatable, loadstring, setfenv, setmetatable from _G
import insert from table

import readFileSync from require "fs"
import loadstring from require "moonscript/base"

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

-- ::loadChunk(function functionChunk) -> table
-- Parses a function chunk as a DataFile
-- export
export loadChunk = (functionChunk) ->
    -- Make the new environment for the chunk then run and return exports
    chunkEnvironment, dataExports = ChunkEnvironment()
    setfenv(functionChunk, chunkEnvironment)()
    return dataExports

-- ::readString(string dataString, string chunkName?) -> table
-- Parses a string as a DataFile
-- (TODO: Use the MoonScript lexer to parse into data, for safer reading)
-- export
export fromString = (dataString, chunkName="DataFile Chunk") ->
    -- Parse the string with MoonScript then load it as a function chunk
    functionChunk = loadstring(dataString, chunkName)
    return loadChunk(functionChunk)

-- ::readFile(string fileName) -> table
-- Reads a file into memory then parses it as a DataFile
-- export
export readFile = (fileName) ->
    fileContent = readFileSync(fileName)
    return fromString(fileContent, fileName)

-- ::toString(table tableData) -> string
-- Writes a table to a string in DataFile format
-- export
export toString = (tableData) ->
    
