import
    assert, error, ipairs, loadfile,
    pcall, pairs, setfenv
from _G
import match from string
import insert from table

import
    existsSync, mkdirSync, readFileSync, writeFileSync,
    unlinkSync from require "fs"
import decode, encode from require "json"
import isAbsolute, join from require "path"
moonscript = require "moonscript"

import merge from "novacbn/novautils/table"

import PROJECT_PATH, SYSTEM_OS_ARCH, SYSTEM_OS_TYPE, SYSTEM_UNIX_LIKE from "novacbn/gmodproj/lib/constants"
import fromString, toString from "novacbn/gmodproj/lib/datafile"
import logError from "novacbn/gmodproj/lib/logging"
import exec, execFormat, isDir, isFile from "novacbn/gmodproj/lib/utilities/fs"
assertx = dependency "novacbn/gmodproj/lib/utilities/assert"

-- ChunkEnvironment::ChunkEnvironment(string environmentRoot, boolean allowUnsafe)
-- Represents a primitive pseudo-sandboxed scripting environment
ChunkEnvironment = (environmentRoot, allowUnsafe) ->
    -- ::getEnvironmentPath(string path) -> string or nil
    -- Normalizes a path to be relative to the scripting environment's working directory only, errors otherwise if unsafe scripting is disabled
    --
    getEnvironmentPath = (path) ->
        -- Only return pathes as relative to the project directory
        return join(environmentRoot, path) unless isAbsolute(path) or match(path, "%.%.")

        -- Only return unsafe pathes if allowed
        return path if allowUnsafe

    -- ::moduleCache -> table
    -- Represents the module cached by `require`
    --
    moduleCache = {}

    -- ::orderedTests -> table
    -- Represents the defined unit tests ordered as defined
    --
    orderedTests = {}

    -- ::unitTests -> table
    -- Represents the defined unit tests
    --
    unitTests = {}

    local environmentTable
    environmentTable = {
        -- ChunkEnvironment::ENV_ALLOW_UNSAFE_SCRIPTING -> boolean
        -- Represents if unsafe scripting is allowed by the user
        -- scripting, safe
        ENV_ALLOW_UNSAFE_SCRIPTING: allowUnsafe

        -- ChunkEnvironment::PROJECT_PATH -> table
        -- Represents the various paths of the current project
        -- scripting, safe
        PROJECT_PATH: PROJECT_PATH

        -- ChunkEnvironment::SYSTEM_OS_ARCH -> boolean
        -- Represents the architecture of the operating system
        -- scripting, safe
        SYSTEM_OS_ARCH: SYSTEM_OS_ARCH

        -- ChunkEnvironment::SYSTEM_OS_TYPE -> boolean
        -- Represents the type of operating system currently running
        -- scripting, safe
        SYSTEM_OS_TYPE: SYSTEM_OS_TYPE

        -- ChunkEnvironment::SYSTEM_UNIX_LIKE -> boolean
        -- Represents if the operating system is unix-like in its environment
        -- scripting, safe
        SYSTEM_UNIX_LIKE: SYSTEM_UNIX_LIKE

        -- ChunkEnvironment::assert(any ...) -> any ...
        -- Lua's built-in assert function
        -- scripting, safe
        assert: assert

        -- ChunkEnvironment::define(string name, function callback) -> void
        -- Defines a unit test to be dispatched when `_G::test` is called
        -- scripting, safe
        define: (name, callback) ->
            error("bad argument #1 to 'define' (expected string)") unless type(name) == "string"
            error("bad argument #1 to 'define' (test already defined)") if unitTests[name]
            error("bad argument #2 to 'define' (expected function)") unless type(callback) == "function"

            unitTests[name] = true
            insert(orderedTests, {
                name:       name
                callback:   callback
            })

        -- ChunkEnvironment::error(string error, number level) -> void
        -- Lua's built-in error function
        -- scripting, safe
        error: error

        -- ChunkEnvironment::exists(string path) -> boolean
        -- Returns true if the path exists within the scripting environment's working directory
        -- scripting, safe
        exists: (path) ->
            -- Validate the path and then return if exists
            path    = assertx.argument(getEnvironmentPath(path), 1, "exists", "expected relative path, got '#{path}'")
            hasPath = existsSync(path)
            return hasPath

        -- ChunkEnvironment::isDir(string path) -> boolean
        -- Returns if the path exists and is a directory
        -- scripting, safe
        isDir: (path) ->
            -- Validate the path and then return if is a directory
            path = assertx.argument(getEnvironmentPath(path), 1, "isDir", "expected relative path, got '#{path}'")
            return isDir(path)

        -- ChunkEnvironment::isFile(string path) -> boolean
        -- Returns if the path exists and is a file
        -- scripting, safe
        isFile: (path) ->
            -- Validate the path and then return if is a file
            path = assertx.argument(getEnvironmentPath(path), 1, "isFile", "expected relative path, got '#{path}'")
            return isFile(path)

        -- ChunkEnvironment::ipairs(table iteratee) -> function
        -- Lua's built-in ipairs function
        -- scripting, safe
        ipairs: ipairs

        -- ChunkEnvironment::mkdir(string path) -> void
        -- Creates a new directory on disk
        -- scripting, safe
        mkdir: (path) ->
            -- Validate the path and then make the directory
            path    = assertx.argument(getEnvironmentPath(path), 1, "mkdir", "expected relative path, got '#{path}'")
            hasPath = existsSync(path)
            assertx.argument(not hasPath, 1, "mkdir", "path '#{path}' already exists")

            mkdirSync(path)
            return nil

        -- ChunkEnvironment::pcall(function protectedFunction, any ...) -> boolean, string or any ...
        -- Lua's built-in pcall function
        -- scripting, safe
        pcall: pcall

        -- ChunkEnvironment::pairs(table iteratee) -> function
        -- Lua's built-in pairs function
        -- scripting, safe
        pairs: pairs

        -- ChunkEnvironment::print(any ...) -> void
        -- Lua's built-in print function, should be used for debugging only
        -- scripting, safe
        print: print

        -- ChunkEnvironment::read(string path) -> string
        -- Reads a file from disk into memory
        -- scripting, safe
        read: (path) ->
            -- Validate the path and then read the file into memory
            path = assertx.argument(getEnvironmentPath(path), 1, "read", "expected relative path, got '#{path}'")
            assertx.argument(isFile(path), 1, "read", "file '#{path}' does not exist")

            return readFileSync(path)

        -- ChunkEnvironment::readDataFile(string path) -> table
        -- Reads a DataFile-format file from disk into memory
        -- scripting, safe
        readDataFile: (path) -> fromString(environmentTable.read(path))

        -- ChunkEnvironment::readJSON(string path) -> table
        -- Reads a JSON-format file from disk into memory
        -- scripting, safe
        readJSON: (path) -> decode(environmentTable.read(path))

        -- ChunkEnvironment::remove(string path) -> void
        -- Removes the path from the disk
        -- scripting, safe
        remove: (path) ->
            -- Validate the path and then remove it
            path = assertx.argument(getEnvironmentPath(path), 1, "remove", "expected relative path, got '#{path}'")

            if isDir(path) then rmdir(path)
            else unlinkSync(path)
            return nil

        -- ChunkEnvironment::test() -> number, string
        -- Dispatches all the define tests, printing each failed test
        -- scripting, safe
        test: () ->
            local success, err
            for unitTest in *orderedTests
                success, err        = pcall(unitTest.callback)
                unitTest.success    = success

                unless success
                    logError("Failed unit test '#{unitTest.name}'\n#{err}")
                    print("")

            -- Calculate all the number of successful tests
            failed      = 0
            successful  = 0
            total       = #orderedTests
            for unitTest in *orderedTests
                if unitTest.success then successful += 1
                else failed += 1

            return 1, "#{successful} successes, #{failed} failed, out of #{total} test(s)" if failed > 0
            return 0, "All #{total} test(s) passed"

        -- ChunkEnvironment::tostring(any value) -> string
        -- Lua's built-in tostring function
        -- scripting, safe
        tostring: tostring

        -- ChunkEnvironment::write(string path, string contents) -> void
        -- Writes to a file on disk
        -- scripting, safe
        write: (path, contents) ->
            -- Validate the path and then write to it
            path = assertx.argument(getEnvironmentPath(path), 1, "write", "expected relative path, got '#{path}'")

            writeFileSync(path, contents)
            return nil

        -- ChunkEnvironment::writeDataFile(string path, table tableData) -> void
        -- Writes to a DataFile-format file on disk
        -- scripting, safe
        writeDataFile: (path, tableData) -> environmentTable.write(path, toString(tableData))

        -- ChunkEnvironment::writeJSON(string path, table tableData) -> void
        -- Writes to a JSON-format file on disk
        -- scripting, safe
        writeJSON: (path, tableData) -> environmentTable.write(path, encode(tableData, {
            indent: true
        }))
    }

    if allowUnsafe then merge(environmentTable, {
        -- ChunkEnvironment::dependency(string assetName, any ...) -> table
        -- Imports a dependency from the running 'gmodproj' project build
        -- scripting, unsafe
        dependency: dependency

        -- ChunkEnvironment::require(string name) -> any
        -- Imports a script from the running 'Luvit' environment
        -- scripting, unsafe
        require: (name) ->
            -- Try to find the script within the project directory
            path    = join(PROJECT_PATH.home, name)
            loader  = nil

            if isFile(path..".lua")
                -- If there is a Lua file, provide the Lua loader
                path    ..= ".lua"
                loader  = loadfile

            elseif isFile(path..".moon")
                -- If there is a MoonScript file, provide the MoonScript loader
                path    ..= ".moon"
                loader  = moonscript.loadfile

            if loader
                -- A loader was present, try to load and cache the module
                unless moduleCache[name]
                    chunk = loader(path)
                    setfenv(chunk, environmentTable)
                    moduleCache[name] = chunk()

                return moduleCache[name]

            -- Try to load the script from gmodproj's included files
            success, exports = pcall(dependency, name)
            return exports if success

            -- If all else fails, use Luvit's require
            return require(name)

        -- ChunkEnvironment::exec(string command) -> boolean, number or nil, string or nil
        -- Executes the shell command if shell and returns the STDOUT and status code
        -- scripting, unsafe
        exec: exec

        -- ChunkEnvironment::execFormat(string ...) -> boolean, number or nil, string or nil
        -- Executes the shell command if shell and returns the STDOUT and status code, formatting the vararg
        -- scripting, unsafe
        execFormat: execFormat
    })

    environmentTable._G = environmentTable

    return setmetatable({}, {__index: environmentTable})

-- ScriptingEnvironment::ScriptingEnvironment()
-- Represents a pseudo-sandboxed environment to run scripts in
-- export
export class ScriptingEnvironment
    -- ScriptingEnvironment::allowUnsafe -> boolean
    -- Represents if the scripting environment allows for unsafe operations
    --
    allowUnsafe: nil

    -- ScriptingEnvironment::environmentRoot -> string
    -- Represents the root path of the scripting environment, that scripts can interact with
    --
    environmentRoot: nil

    -- ScriptingEnvironment::new(string environmentRoot, boolean allowUnsafe)
    -- Constructor for ScriptingEnvironment
    --
    new: (environmentRoot, allowUnsafe) =>
        -- Store the environment variables
        @allowUnsafe        = allowUnsafe
        @environmentRoot    = environmentRoot

    -- ScriptingEnvironment::executeChunk(function scriptChunk, any ...) -> boolean, string or any ...
    -- Wraps the script chunk in a pseudo-sandboxed environment, then executes with, returning its results
    --
    executeChunk: (scriptChunk, ...) =>
        -- Make a new environment for the executing chunk, then run it
        environmentSandbox = ChunkEnvironment(@environmentRoot, @allowUnsafe)
        return pcall(setfenv(scriptChunk, environmentSandbox), ...)
