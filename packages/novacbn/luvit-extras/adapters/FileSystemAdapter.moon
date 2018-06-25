import type from _G
import gsub from string

import
    access, accessSync, exists, existsSync,
    readdir, readdirSync, readFile, readFileSync,
    rename, renameSync, rmdir, rmdirSync,
    stat, statSync, unlink, unlinkSync,
    writeFile, writeFileSync, walk, walkSync from require "fs"
import normalize, normalizeSeparators, relative, resolve from require "path"

import isdirSync, walk, walkSync from "novacbn/luvit-extras/fs"
import VirtualAdapter from "novacbn/luvit-extras/vfs"

-- ::PATTERN_SANITIZE_ESCAPE -> string
-- Represents a Lua pattern to santize directory escapes
--
PATTERN_SANITIZE_ESCAPE = "%.%."

-- ::PATTERN_SANITIZE_SEPARATORS -> string
-- Represents a Lua pattern to sanitize backslash separators
--
PATTERN_SANITIZE_SEPARATORS = "\\"

-- ::makeResolvedFunction(function func, boolean isAsync?, boolean sanitizeResults?) -> function
-- Adapts a filesystem API to automatically resolve virtual paths
--
makeResolvedFunction = (func, isAsync=false, sanitizeResults=false) ->
    if isAsync
        return (self, path, callback) ->
            if sanitizeResults
                return func(self\resolve(path), (err, results) ->
                    return callback(err, self\sanitize(results))
                )

            func(self\resolve(path), callback)

    return (self, path, ...) ->
        results, err    = func(self\resolve(path), ...)
        results         = self\sanitize(results) if sanitizeResults

        error(err) if err
        return results

-- FileSystemAdapter::FileSystemAdapter()
-- Represents an adapter for the local file system
-- export
export FileSystemAdapter = with VirtualAdapter\extend()
    -- FileSystemAdapter::root -> string
    -- Represents the root directory this virtual adapter is reading from
    --
    .root = nil

    -- FileSystemAdapter::initialize(string root, boolean readOnly?) -> void
    -- Constructor for FileSystemAdapter
    --
    .initialize = (root, readOnly=false) =>
        error("bad argument #1 to 'initialize' (expected string)") unless type(root) == "string"

        root = resolve(root)
        error("bad argument #1 to 'initialize' (expected directory)") unless isdirSync(root)
        error("bad argument #2 to 'initialize' (expected boolean)") unless type(readOnly) == "boolean"

        @root = root
        VirtualAdapter.initialize(self, readOnly)

    -- FileSystemAdapter::resolve(string path) -> string
    -- Sanitizes and resolves the path to within the root directory
    --
    .resolve = (path) =>
        error("bad argument #1 to 'resolve' (unexpected escaping path)") if gsub(path, PATTERN_SANITIZE_ESCAPE, "") ~= path
        return resolve(@root, normalize(path))

    -- FileSystemAdapter::sanitize(string or table path) -> string or table
    -- Santizes the specified path to be uniform across platforms with the root directory removed
    --
    .sanitize = (path) =>
        error("bad argument #1 'sanitize' (expected string)") unless type(path) == "string" or "table"

        if type(path) == "string"
            path = gsub(path, PATTERN_SANITIZE_SEPARATORS, "/")
            return relative(@root, path)

        for index, value in ipairs(path)
            value       = gsub(value, PATTERN_SANITIZE_SEPARATORS, "/")
            path[index] = relative(@root, value)

        return path

    -- FileSystemAdapter::access(string path, function callback) -> void
    --
    --
    .access = makeResolvedFunction(access, true)

    -- FileSystemAdapter::accessSync(string path) -> boolean
    --
    --
    .accessSync = makeResolvedFunction(accessSync)

    -- FileSystemAdapter::readdir(string directory, function callback) -> void
    --
    --
    .readdir = makeResolvedFunction(readdir, true)

    -- FileSystemAdapter::readdirSync(string directory) -> table
    --
    --
    .readdirSync = makeResolvedFunction(readdirSync, false)

    -- FileSystemAdapter::readFile(string file, function callback) -> void
    --
    --
    .readFile = makeResolvedFunction(readFile, true)

    -- FileSystemAdapter::readFileSync(string file) -> string
    --
    --
    .readFileSync = makeResolvedFunction(readFileSync)

    -- FileSystemAdapter::rmdir(string directory, function callback) -> void
    --
    --
    .rmdir = makeResolvedFunction(rmdir, true)

    -- FileSystemAdapter::rmdirSync(string directory) -> void
    --
    --
    .rmdirSync = makeResolvedFunction(rmdirSync)

    -- FileSystemAdapter::stat(string path, function callback) -> void
    --
    --
    .stat = makeResolvedFunction(stat, true)

    -- FileSystemAdapter::statSync(string path, function callback) -> table
    --
    --
    .statSync = makeResolvedFunction(statSync)

    -- FileSystemAdapter::unlink(string file, function callback) -> void
    --
    --
    .unlink = makeResolvedFunction(unlink, true)

    -- FileSystemAdapter::unlinkSync(string file) -> void
    --
    --
    .unlinkSync = makeResolvedFunction(unlinkSync)

    -- FileSystemAdapter::writeFile(string file, string contents, function callback) -> void
    --
    --
    .writeFile = makeResolvedFunction(writeFile, true)

    -- FileSystemAdapter::writeFileSync(string file, string contents) -> void
    --
    --
    .writeFileSync = makeResolvedFunction(writeFileSync)

    -- FileSystemAdapter::walk(string directory, function callback) -> void
    --
    --
    .walk = makeResolvedFunction(walk, true, true)

    -- FileSystemAdapter::walkSync(string directory) -> void
    --
    --
    .walkSync = makeResolvedFunction(walkSync, false, true)