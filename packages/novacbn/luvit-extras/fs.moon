import ipairs, pairs, type from _G
import insert from table

import
    access, accessSync, readdir, readdirSync,
    stat, statSync from require "fs"
import join from require "path"
import setTimeout from require "timer"
import nextTick from process

-- ::handleStat(string path, string check, function callback) -> void
-- Helper function for handling the accessibity and type check of paths
--
handleStat = (path, check, callback) ->
    access(path, (err) ->
        if err then return callback(err, false)

        stat(path, (err, stats) ->
            if err or stats.type ~= check then return callback(err, false)
            callback(nil, true)
        )
    )

    return nil

-- DirectoryPoll::DirectoryPoll()
-- Represents a directory being polled for changes
--
DirectoryPoll = (directory, tickRate, callback) -> {
    -- DirectoryPoll::closed -> boolean
    -- Represents if the DirectoryPoll is no longer watching
    --
    closed: false

    -- DirectoryPoll::directory -> string
    -- Represents the directory that is being watched
    --
    directory: directory

    -- DirectoryPoll::files -> table
    -- Represents the cache of file modification timestamps under the directory
    --
    files: {}

    -- DirectoryPoll::type -> string
    -- Represents which type of entry this is for
    --
    type: "directory"

    -- DirectoryPoll::close(string reason?) -> void
    -- Closes the DirectoryPoll and stops watching the filesystem
    --
    close: (reason="DirectoryPoll was closed") =>
        -- Close the DirectoryPoll before dispatch
        @closed = true
        callback(reason, nil)
        return nil

    -- DirectoryPoll::scan() -> void
    -- Scans if any files under the directory have changed
    --
    scan: () =>
        return if @closed

        -- NOTE: this should be rewritten as a coroutine for non-blocking operations
        walk(directory, (err, names) ->
            if err then return @close(err)

            -- Reset the checked flags in files
            entry.checked = false for name, entry in pairs(@files)

            -- Scan the files in the directory for changes
            local entry, lastModified
            for name in *names
                -- Skip if not a file or accessible
                continue unless isfileSync(name)

                -- If an entry does not exist, make one and call 'renamed' event,
                -- if does exist and was modified, call 'changed' event
                entry = @files[name]
                if entry
                    entry.checked = true

                    lastModified = statSync(name).mtime.sec
                    unless entry.lastModified == lastModified
                        entry.lastModified = lastModified
                        callback(nil, "changed", name)

                else
                    @files[name] = {
                        checked:        true
                        lastModified:   statSync(name).mtime.sec
                    }

                    callback(nil, "renamed", name)

            -- Check for any inaccessible or otherwise removed files
            for name, entry in pairs(@files)
                unless entry.checked
                    @files[name] = nil
                    callback(nil, "renamed", name)

            if tickRate == 0 then nextTick(self\scan)
            else setTimeout(tickRate, self\scan)
        )
}

-- FilePoll::FilePoll()
-- Represents a file being polled for changes
--
FilePoll = (file, tickRate, callback) -> {
    -- FilePoll::closed -> boolean
    -- Represents if the FilePoll is no longer watching
    --
    closed: false

    -- FilePoll::file -> string
    -- Represents the file that is being watched
    --
    file: file

    -- FilePoll::lastModified -> number
    -- Represents the last time the file was modified
    --
    lastModified: statSync(file).mtime.sec

    -- FilePoll::type -> string
    -- Represents which type of entry this is for
    --
    type: "file"

    -- FilePoll::close(string reason?) -> void
    -- Closes the FilePoll and stops watching the filesystem
    --
    close: (reason="FilePoll was closed") =>
        -- Close the FilePoll before dispatch
        @closed = true
        callback(reason, nil)
        return nil

    -- FilePoll::scan() -> void
    -- Scans if the file has changed since last
    --
    scan: () =>
        return if @closed

        -- NOTE: this should be rewritten as a coroutine for non-blocking operations
        access(file, (err) ->
            if err then return @close(err)

            stat(file, (err, stats) ->
                if err then return @close(err)

                if stats.mtime.sec ~= @lastModified
                    @lastModified = stats.mtime.sec
                    callback(nil, file)

                if tickRate == 0 then nextTick(self\scan)
                else setTimeout(tickRate, self\scan)
            )
        )
}

-- ::isdir(string directory, function callback) -> void
-- Returns if the provided path does exist and is a directory
-- export
export isdir = (directory, callback) ->
    error("bad argument #1 to 'isdir' (expected string)") unless type(directory) == "string"
    error("bad argument #2 to 'isdir' (expected function)") unless type(callback) == "function"

    handleStat(directory, "directory", callback)

-- ::isdirSync(string directory) -> boolean
-- Synchronous variant of `isdir`
-- export
export isdirSync = (directory) ->
    error("bad argument #1 to 'isdir' (expected string)") unless type(directory) == "string"

    return accessSync(directory) and statSync(directory).type == "directory" and true or false

-- ::isfile(string file, function callback) -> void
-- Returns if the provided path does exist and is a file
-- export
export isfile = (file, callback) ->
    error("bad argument #1 to 'isfile' (expected string)") unless type(file) == "string"
    error("bad argument #2 to 'isfile' (expected function)") unless type(callback) == "function"

    handleStat(file, "file", callback)

-- ::isfileSync(string file) -> boolean
-- Synchronous variant of `isfile`
-- export
export isfileSync = (file) ->
    error("bad argument #1 to 'isfileSync' (expected string)") unless type(file) == "string"

    return accessSync(file) and statSync(file).type == "file" and true or false

-- ::walk(string directory, function callback, table results?) -> void
-- Walks a directory, collecting all paths inside of it recursively
-- export
export walk = (directory, callback, results={}) ->
    error("bad argument #1 to 'walk' (expected string)") unless type(directory) == "string"
    error("bad argument #2 to 'walk' (expected function)") unless type(callback) == "function"

    readdir(directory, (err, names) ->
        if err then return callback(err, nil)

        -- Pre-calculate the amount of entries to process and check if empty
        pending = #names
        if pending < 1 then return callback(nil, results)

        for name in *names
            name = join(directory, name)

            stat(name, (err, stats) ->
                insert(results, name)

                -- If the entry is a directory, recursively walk, otherwise do nothing
                if stats and stats.type == "directory"
                    walk(name, () ->
                        pending -= 1
                        callback(nil, results) if pending < 1, results)

                else
                    pending -= 1
                    callback(nil, results) if pending < 1
            )
    )

-- ::walkSync(string directory) -> table
-- Synchronous variant of `walk`
-- export
export walkSync = (directory, results={}) ->
    error("bad argument #1 to 'walkSync' (expected string)") unless type(directory) == "string"
    error("bad argument #1 to 'walkSync' (no such directory)") unless isdirSync(directory)

    local stats
    for name in *readdirSync(directory)
        name = join(directory, name)

        -- Insert the directory entry into the paths, then recursively walk if directory
        insert(results, name)

        stats = statSync(name)
        walkSync(name, results) if stats and stats.type == "directory"

    return results

-- ::watchPoll(string path, number tickRate?, function listener) -> DirectoryPoll or FilePoll
-- Watches a path for changes with polling, with the following signature `listener(string err?, string event?, string file?)`
--
-- For watching files in a directory:
-- ```lua
-- -- Start watching a directory
-- directoryPoll = watchPoll("mydirectory", function (err, event, file)
--     if event == "changed" then
--         print("file '"..file.."' was changed!")
--     elseif event == "renamed" then
--         print("file '"..file.."' was (re)moved or renamed!")
--     end
-- end)
--
-- -- Later to stop watching
-- directoryPoll:close()
-- ```
--
-- For watching a specific file
-- ```lua
-- -- Start watching a file
-- filePoll = watchPoll("myfile.txt", function (err, file)
--     print("file '"..file.."' was changed!")
-- end)
--
-- -- Later to stop watching
-- filePoll:close()
-- ```
-- export
export watchPoll = (path, tickRate, listener) ->
    if type(tickRate) == "function"
        listener    = tickRate
        tickRate    = 0

    error("bad argument #1 to 'watch' (expected string)") unless type(path) == "string"
    error("bad argument #1 to 'watch' (expected directory or file)") unless isdirSync(path) or isfileSync(path)
    error("bad argument #2 to 'watch' (expected number)") unless type(tickRate) == "number"
    error("bad argument #2 to 'watch' (expected positive tick rate)") unless tickRate > -1
    error("bad argument #3 to 'watch' (expected function)") unless type(listener) == "function"

    -- Make the proper filesystem entry and start its scanning
    entry = isdirSync(path) and DirectoryPoll(path, tickRate, listener) or FilePoll(path, tickRate, listener)
    nextTick(entry\scan)
    return entry