import ipairs from _G
import popen from io
import match from string
import concat, insert from table

import statSync from require "fs"

-- ::formatCommand(string ...) -> string
-- Formats the string vararg provided into a proper command string, quoting any arguments with spaces
export formatCommand = (...) ->
    -- Convert the vararg into a table then process the arguments
    commandArguments = {...}
    for index, commandArgument in ipairs(commandArguments)
        -- Wrap the string in quotations if it has a spacing character
        commandArguments[index] = "'#{commandArgument}'" if match(commandArgument, "%s")

    -- Return concatenate the command arguments by space
    return concat(commandArguments, " ")

-- ::exec(string command) -> boolean, number or nil, string or nil
-- Executes the command, returning the status code and stdout
export exec = (command) ->
    -- Open the process and return the output
    -- NOTE: Luvit is compiled to return the sigterm and status with io.popen
    handle              = popen(command, "r")
    stdout              = handle\read("*a")
    success, _, status  = handle\close()
    return success, status, stdout

-- ::execFormat(string ...) -> boolean, number or nil, string or nil
-- Executes the command, formatting the arguments together, returning the status code and stdout
export execFormat = (...) ->
    -- Format the arguments and execute the command
    return exec(formatCommand(...))

-- ::isDir(string path) -> boolean
-- Returns if the path is a directory
export isDir = (path) ->
    fileStats = statSync(path)
    return fileStats and fileStats.type == "directory" or false

-- ::isFile(string path) -> boolean
-- Returns if the path is a file
export isFile = (path) ->
    fileStats = statSync(path)
    return fileStats and fileStats.type == "file" or false