import ipairs, unpack from _G
import open from io
import execute, tmpname from os
import match from string
import concat, insert from table

import readFileSync, statSync from require "fs"
import pack from require "glue"

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

-- ::exec(string command, string ...) -> string, number or nil
-- Executes the command and returns the resulting STDOUT and return code
export exec = (command, ...) ->
    -- Construct the command and execute
    logFile         = tmpname()
    execArguments   = pack(...)
    insert(execArguments, ">")
    insert(execArguments, logFile)
    success, _, status = execute(command.." "..formatCommand(unpack(execArguments)))

    -- Return the command STDOUT and status
    return readFileSync(logFile), success and status

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