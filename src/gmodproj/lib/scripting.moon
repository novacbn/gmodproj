import error, pcall, setfenv from _G
import match from string

import
    existsSync, mkdirSync, readFileSync, writeFileSync,
    unlinkSync
from require "fs"
import merge from require "glue"
import isAbsolute, join, relative from require "path"

import ENV_ALLOW_UNSAFE_SCRIPTING, PATH_DIRECTORY_PROJECT, SYSTEM_OS_ARCH, SYSTEM_OS_TYPE from "gmodproj/lib/constants"
import exec, isDir, isFile from "gmodproj/lib/fsx"

-- ::getProjectPath(string path) -> string
-- Normalizes a to be absolute to the project's directory only, otherwise returns nothing
getProjectPath = (path) ->
    -- If the path is absolute, already discard it
    unless isAbsolute(path)
        -- Get the path as relative to working directory, skip if it has directory escapes in it
        relativePath = relative(PATH_DIRECTORY_PROJECT, path)
        return join(PATH_DIRECTORY_PROJECT, relativePath) unless match(relativePath, "%.%.")

    -- Error to the script if the path is not relative
    error("Path must be relative to the project's working directory!")

-- EnvironmentTable -> table
-- Represents the environment exported to the globals of the script
EnvironmentGlobals =
    :ENV_ALLOW_UNSAFE_SCRIPTING, :pcall, :print, :SYSTEM_OS_ARCH, :SYSTEM_OS_TYPE, :tostring

    -- EnvironmentTable::dependency(string assetName, any ...) -> table
    -- Imports a dependency from the running 'gmodproj' project build, only allowed if unsafe scripting is enabled
    dependency: ENV_ALLOW_UNSAFE_SCRIPTING and dependency or nil

    -- EnvironmentTable::require(string importName) -> any
    -- Imports a script from the running 'Luvit' environment, only allowed if unsafe scripting is enabled
    require: ENV_ALLOW_UNSAFE_SCRIPTING and require or nil

    -- EnvironmentTable::exec(string ...) -> string, number or nil
    -- Executes the shell command if shell and returns the STDOUT and status code, only allowed if unsafe scripting is enabled
    exec: (...) ->
        -- Validate shell scripting is allowed before execution
        error("Unsafe scripting is disabled by the user!") unless ENV_ALLOW_UNSAFE_SCRIPTING
        return exec(...)

    -- EnvironmentTable::isDir(string path) -> boolean
    -- Returns true if the path is a directory within the project's working directory
    isDir: (path) ->
        -- Validate the path, then return if it is a directory
        path    = getProjectPath(path)
        hasPath = existsSync(path)
        return existsSync(path) and isDir(path)

    -- EnvironmentTable::isFile(string path) -> boolean
    -- Returns true if the path is a file within the project's working directory
    isFile: (path) ->
        -- Validate the path, then return if it is a file
        path    = getProjectPath(path)
        hasPath = existsSync(path)
        return existsSync(path) and isFile(path)

    -- EnvironmentTable::exists(string path) -> boolean
    -- Returns true if the path exists within the project's working directory
    exists: (path) ->
        -- Validate the path, then return if it exists
        path    = getProjectPath(path)
        hasPath = existsSync(path)
        return hasPath

    -- EnvironmentTable::mkdir(string path) -> void
    -- Creates a new directory within the project's working directory
    mkdir: (path) ->
        -- Validate the path, then return if it exists
        path = getProjectPath(path)
        return mkdirSync(path)

    -- EnvironmentTable::read(string path) -> string
    -- Reads a file from the project's working directory into memory
    read: (path) ->
        -- Validate the path, then read the file
        path = getProjectPath(path)
        return readFileSync(path)

    -- EnvironmentTable::remove(string path) -> void
    -- Removes the path from the project's working directory
    remove: (path) ->
        -- Validate the path, then remove the path
        path = getProjectPath(path)
        if isDir(path) then rmdir(path)
        else unlinkSync(path)

        return nil

    -- EnvironmentTable::write(string path, string contents) -> void
    -- Writes to a file in the project's working directory
    write: (path, contents) ->
        -- Validate the path, then write the file
        path = getProjectPath(path)
        writeFileSync(path, contents)
        return nil

-- ChunkEnvironment::ChunkEnvironment()
-- Represents a primitive scripting environment for manifest scripts
ChunkEnvironment = () -> setmetatable(merge({}, EnvironmentGlobals), {})

-- ::setEnvironment(function scriptChunk) -> function
-- Configures the environment of the script's function chunk
export setEnvironment = (scriptChunk) ->
    chunkEnvironment = ChunkEnvironment()
    return setfenv(scriptChunk, chunkEnvironment)