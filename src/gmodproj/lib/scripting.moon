import
    error, ipairs, pcall, pairs,
    setfenv
from _G
import match from string

import
    existsSync, mkdirSync, readFileSync, writeFileSync,
    unlinkSync
from require "fs"
import update from require "glue"
import decode, encode from require "json"
import isAbsolute, join from require "path"

import SYSTEM_OS_ARCH, SYSTEM_OS_TYPE from "gmodproj/lib/constants"
import fromString, toString from "gmodproj/lib/datafile"
import exec, isDir, isFile from "gmodproj/lib/fsx"

-- ChunkEnvironment::ChunkEnvironment(string environmentRoot, boolean allowUnsafe)
-- Represents a primitive pseudo-sandboxed scripting environment
ChunkEnvironment = (environmentRoot, allowUnsafe) ->
    -- ::getEnvironmentPath(string path) -> string
    -- Normalizes a path to be relative to the scripting environment's working directory only, errors otherwise if unsafe scripting is disabled
    getEnvironmentPath = (path) ->
        -- If the path is absolute, don't allow is in safe mode
        unless isAbsolute(path)
            -- Validate the path then join to the scripting environment's working directory
            error("Path cannot have parent directive!") if not allowUnsafe and match(path, "%.%.")
            return join(environmentRoot, path)

        -- Error to the script if the path is not relative
        error("Path must be relative to the scripting environment's working directory!") unless allowUnsafe
        return path

    local environmentTable
    environmentTable = {
        -- environmentTable::ENV_ALLOW_UNSAFE_SCRIPTING -> boolean
        -- Represents if unsafe scripting is allowed by the user
        -- scripting, safe
        ENV_ALLOW_UNSAFE_SCRIPTING: allowUnsafe

        -- environmentTable::SYSTEM_OS_ARCH -> boolean
        -- Represents the architecture of the operating system
        -- scripting, safe
        SYSTEM_OS_ARCH: SYSTEM_OS_ARCH

        -- environmentTable::SYSTEM_OS_TYPE -> boolean
        -- Represents the type of operating system currently running
        -- scripting, safe
        SYSTEM_OS_TYPE: SYSTEM_OS_TYPE

        -- environmentTable::exists(string path) -> boolean
        -- Returns true if the path exists within the scripting environment's working directory
        -- scripting, safe
        exists: (path) ->
            -- Validate the path, then return if it exists
            path    = getEnvironmentPath(path)
            hasPath = existsSync(path)
            return hasPath

        -- environmentTable::isDir(string path) -> boolean
        -- Returns true if the path is a directory within the scripting environment's working directory
        -- scripting, safe
        isDir: (path) ->
            -- Validate the path, then return if it is a directory
            path = getEnvironmentPath(path)
            return isDir(path)

        -- environmentTable::isFile(string path) -> boolean
        -- Returns true if the path is a file within the scripting environment's working directory
        -- scripting, safe
        isFile: (path) ->
            -- Validate the path, then return if it is a file
            path = getEnvironmentPath(path)
            return isFile(path)

        -- environmentTable::ipairs(table iteratee) -> function
        -- Lua's built-in ipairs function
        -- scripting, safe
        ipairs: ipairs

        -- environmentTable::mkdir(string path) -> void
        -- Creates a new directory within the scripting environment's working directory
        -- scripting, safe
        mkdir: (path) ->
            -- Validate the path, then return if it exists
            path = getEnvironmentPath(path)
            mkdirSync(path)
            return nil

        -- environmentTable::pcall(function protectedFunction, any ...) -> boolean, string or any ...
        -- Lua's built-in pcall function
        -- scripting, safe
        pcall: pcall

        -- environmentTable::pairs(table iteratee) -> function
        -- Lua's built-in pairs function
        -- scripting, safe
        pairs: pairs

        -- environmentTable::print(any ...) -> void
        -- Lua's built-in print function, should be used for debugging only
        -- scripting, safe
        print: print

        -- environmentTable::read(string path) -> string
        -- Reads a file from the scripting environment's working directory into memory
        -- scripting, safe
        read: (path) ->
            -- Validate the path, then read the file
            path = getEnvironmentPath(path)
            return readFileSync(path)

        -- environmentTable::readDataFile(string path) -> string
        -- Reads a DataFile-format file from the scripting environment's working directory into memory
        -- scripting, safe
        readDataFile: (path) -> fromString(environmentTable.read(path))

        -- environmentTable::readJSON(string path) -> string
        -- Reads a JSON-format file from the scripting environment's working directory into memory
        -- scripting, safe
        readJSON: (path) -> decode(environmentTable.read(path))

        -- environmentTable::remove(string path) -> void
        -- Removes the path from the scripting environment's working directory
        -- scripting, safe
        remove: (path) ->
            -- Validate the path, then remove the path
            path = getEnvironmentPath(path)
            if isDir(path) then rmdir(path)
            else unlinkSync(path)

            return nil

        -- environmentTable::tostring(any value) -> string
        -- Lua's built-in tostring function
        -- scripting, safe
        tostring: tostring

        -- environmentTable::write(string path, string contents) -> void
        -- Writes to a file in the scripting environment's working directory
        -- scripting, safe
        write: (path, contents) ->
            -- Validate the path, then write the file
            path = getEnvironmentPath(path)
            writeFileSync(path, contents)
            return nil

        -- environmentTable::writeDataFile(string path, table tableData) -> void
        -- Writes to a DataFile-format file in the scripting environment's working directory
        -- scripting, safe
        --writeDataFile: (path, tableData) -> environmentTable.write(path, toString(tableData))
        writeDataFile: (path, tableData) -> environmentTable.write(path, toString(tableData))

        -- environmentTable::writeJSON(string path, table tableData) -> void
        -- Writes to a JSON-format file in the scripting environment's working directory
        -- scripting, safe
        writeJSON: (path, tableData) -> environmentTable.write(path, encode(tableData, {
            indent: true
        }))
    }

    if allowUnsafe then update(environmentTable, {
        -- environmentTable::dependency(string assetName, any ...) -> table
        -- Imports a dependency from the running 'gmodproj' project build
        -- scripting, unsafe
        dependency: dependency

        -- environmentTable::require(string importName) -> any
        -- Imports a script from the running 'Luvit' environment
        -- scripting, unsafe
        require: require

        -- environmentTable::exec(string ...) -> string, number or nil
        -- Executes the shell command if shell and returns the STDOUT and status code
        -- scripting, unsafe
        exec: (...) -> exec(...)
    })

    return setmetatable({}, {__index: environmentTable})

-- ScriptingEnvironment::ScriptingEnvironment()
-- Represents a pseudo-sandboxed environment to run scripts in
export class ScriptingEnvironment
    -- ScriptingEnvironment::allowUnsafe -> boolean
    -- Represents if the scripting environment allows for unsafe operations
    allowUnsafe: nil

    -- ScriptingEnvironment::environmentRoot -> string
    -- Represents the root path of the scripting environment, that scripts can interact with
    environmentRoot: nil

    -- ScriptingEnvironment::new(string environmentRoot, boolean allowUnsafe)
    -- Constructor for ScriptingEnvironment
    new: (environmentRoot, allowUnsafe) =>
        -- Store the environment variables
        @allowUnsafe        = allowUnsafe
        @environmentRoot    = environmentRoot

    -- ScriptingEnvironment::executeChunk(function scriptChunk, any ...) -> boolean, string or any ...
    -- Wraps the script chunk in a pseudo-sandboxed environment, then executes with, returning its results
    executeChunk: (scriptChunk, ...) =>
        -- Make a new environment for the executing chunk, then run it
        environmentSandbox = ChunkEnvironment(@environmentRoot, @allowUnsafe)
        return pcall(setfenv(scriptChunk, environmentSandbox), ...)
