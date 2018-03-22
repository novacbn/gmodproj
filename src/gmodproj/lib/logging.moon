-- Using a bit of https://github.com/rxi/log.lua for formatting

import pairs, tostring, type from _G
import getinfo from debug
import open from io
import date from os
import format from string
import insert from table

import join from require "path"

import PATH_DIRECTORY_LOGS from "gmodproj/lib/constants"

-- ::PATH_FILE_LOG -> string
-- File path representing the currently opened log file
PATH_FILE_LOG = join(PATH_DIRECTORY_LOGS, date("%Y%m%d-%H%M%S.log"))

-- ::HANDLE_CURRENT_LOG -> file or nil
-- Represents the file handle for the currently opened log file
HANDLE_CURRENT_LOG = nil

-- ::OPTIONS_ERROR_LOOKUP -> table
-- Represents a lookup table for the LIVR validation errors
OPTIONS_ERROR_LOOKUP =
    NOT_STRING:     "expected string value"
    NOT_BOOLEAN:    "expected boolean value"
    WRONG_FORMAT:   "option did not match pattern"

-- ::fileMemoryLog -> table or nil
-- Represents a table of string lines cached in-memory until file logging is enabled
fileMemoryLog = {}

-- ::makeLogger(string level, boolean defaultFile, boolean defaultConsole, boolean traceMessage, boolean bailProcess) -> function
-- Makes a wrapper logger for the logging level
makeLogger = (level, levelColor, defaultFile, defaultConsole, traceMessage, bailProcess) ->
    -- Return logging wrapper function
    return (message, toFile, toConsole, statusCode=1) ->
        -- Use the wrapped defaults for user defaulted values
        toFile      = defaultFile if toFile == nil
        toConsole   = defaultConsole if toConsole == nil

        -- Get the debug information about the calling environment and format
        traceLine = ""
        if traceMessage
            debugInfo   = getinfo(2, "Sl")
            traceLine   = " #{debugInfo.short_src}:#{debugInfo.currentline}:"

        -- Print to console if we're outputting there
        if toConsole
            print(format(
                "%s[%-6s%s]%s%s %s",
                levelColor, level, date("%H:%M:%S"),
                "\27[0m", traceLine, message
            ))

        -- Append to log file if we're outputting there
        if toFile
            fileLog = format(
                "[%-6s%s]%s %s\n",
                level, date(),
                traceLine, message
            )

            if fileMemoryLog then insert(fileMemoryLog, fileLog)
            else HANDLE_CURRENT_LOG\write(fileLog)

        -- If this log level needs to bail the process, use the provided status code
        process\exit(statusCode) if bailProcess

export enableFileLogging = () ->
    -- Only enable if not previously enabled
    if fileMemoryLog
        -- Write the backlog into the log file
        HANDLE_CURRENT_LOG = open(PATH_FILE_LOG, "wb")
        HANDLE_CURRENT_LOG\write(fileLog) for fileLog in *fileMemoryLog
        fileMemoryLog = nil

-- ::logInfo(string message, boolean toFile?, boolean toConsole?) -> nil
-- Logs a developer tracing message to the console
export logTrace = makeLogger "TRACE", "\27[34m", false, true, true, false

-- ::logDebug(string message, boolean toFile?, boolean toConsole) -> nil
-- Logs a developer message to the console
export logDebug = makeLogger "DEBUG", "\27[36m", false, true, true, false

-- ::logInfo(string message, boolean toFile?, boolean toConsole?) -> nil
-- Logs an informational message to the console and file
export logInfo = makeLogger "INFO", "\27[32m", true, true, false, false

-- ::logWarn(string message, boolean toFile?, boolean toConsole?) -> nil
-- Logs a user warning message to the console and file
export logWarn = makeLogger "WARN", "\27[33m", true, true, false, false

-- ::logError(string message, boolean toFile?, boolean toConsole?) -> nil
-- Logs a user error message to the console and file
export logError = makeLogger "ERROR", "\27[31m", true, true, false, false

-- ::logFatal(string message, boolean toFile?, boolean toConsole?, number statusCode?) -> nil
-- Logs a fatal user error to the console and file and bails the process
export logFatal = makeLogger "FATAL", "\27[35m", true, true, false, true

-- ::logOptionsError(string parentName, table errors, boolean firstUse?) -> nil
-- Logs LIVR-based errors and bails on the process with the parent name
export logOptionsError = (parentName, errors, firstUse=true) ->
    -- Capture all errors within the options
    for name, id in pairs(errors)
        switch type(id)
            when "string" then logError("bad option '#{name}' to '#{parentName}' (#{OPTIONS_ERROR_LOOKUP[id] or id})")
            when "table"
                if #parentName > 0 then logOptionsError("#{parentName}.#{name}", id, false)
                else logOptionsError("#{name}", id, false)

    -- Finally write a fatal log message
    logFatal("There was an error processing your project's manifest!") if firstUse