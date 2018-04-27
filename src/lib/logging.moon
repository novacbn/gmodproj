-- Using a bit of https://github.com/rxi/log.lua for formatting

import open from io
import date from os
import format from string

import join from require "path"

import merge from "novacbn/novautils/table"
import WriteBuffer from "novacbn/novautils/io/WriteBuffer"

import PROJECT_PATH from "novacbn/gmodproj/lib/constants"

-- ::BUFFER_MEMORY_LOG -> WriteBuffer or nil
-- Represents a in-memory buffer for file logging until physical file logging is enabled
BUFFER_MEMORY_LOG = WriteBuffer\new()

-- ::HANDLE_FILE_LOG -> file or nil
-- Represents the file handle for the currently opened log file
--
HANDLE_FILE_LOG = nil

-- ::PATH_FILE_LOG -> string
-- Represents the file used for logging of this application session
--
PATH_FILE_LOG = join(PROJECT_PATH.logs, date("%Y%m%d-%H%M%S.log"))

-- ::TOGGLE_CONSOLE_LOGGING -> boolean
-- Represents the if the application will log to console
--
TOGGLE_CONSOLE_LOGGING = true

-- ::TOGGLE_FILE_LOGGING -> boolean
-- Represents the if the application will log to file
--
TOGGLE_FILE_LOGGING = true

-- ::makeLogger(string tag, string color, table defaultOptions?) -> function
-- Makes a new logger function using the provided values
--
makeLogger = (tag, color, defaultOptions={}) ->
    return (message, options={}) ->
        options = merge(options, defaultOptions)

        -- If specified to output to console, print formatted message
        if TOGGLE_CONSOLE_LOGGING and options.console
            print(format(
                "%s[%-6s%s]%s %s",
                color, tag, date("%H:%M:%S"),
                "\27[0m", message
            ))

        -- If specified to output to file, write to the current buffer or file
        if TOGGLE_FILE_LOGGING and options.file
            logMessage = format(
                "[%-6s%s] %s\n",
                tag, date(), message
            )

            if BUFFER_MEMORY_LOG then BUFFER_MEMORY_LOG\writeString(logMessage)
            else HANDLE_FILE_LOG\write(logMessage)

        -- If a status code if provided, exit the process with it
        process\exit(options.exit) if options.exit

-- ::enableFileLogging() -> void
-- Enables physical file logging and dumps current memory buffer into log
-- export
export enableFileLogging = () ->
    -- Only enable physical logging if previously not enabled
    if BUFFER_MEMORY_LOG
        -- Open logging file and empty buffer into it
        HANDLE_FILE_LOG = open(PATH_FILE_LOG, "wb")
        HANDLE_FILE_LOG\write(BUFFER_MEMORY_LOG\toString())
        BUFFER_MEMORY_LOG = nil

-- ::toggleConsoleLogging() -> void
-- Allows toggling of console log output
-- export
export toggleConsoleLogging = (toggle) ->
    TOGGLE_CONSOLE_LOGGING = toggle and true or false

-- ::toggleFileLogging() -> void
-- Allows toggling of file log output
-- export
export toggleFileLogging = (toggle) ->
    TOGGLE_FILE_LOGGING = toggle and true or false

-- ::logInfo(string message, boolean toFile?, boolean toConsole?) -> nil
-- Logs a developer tracing message to the console
--makeLogger "TRACE", "\27[34m", false, true, true, false

-- ::logDebug(string message, boolean toFile?, boolean toConsole) -> nil
-- Logs a developer message to the console
--makeLogger "DEBUG", "\27[36m", false, true, true, false 

-- ::logInfo(string message, table options) -> void
-- Logs a message formatted as an INFO message, used for notifying users about normal operations, i.e. successful project building
-- export
export logInfo = makeLogger("INFO", "\27[32m", {
    console:    true,
    file:       true
})

-- ::logWarn(string message, table options) -> void
-- Logs a message formatted as an WARN message, used for warning users about potentially improper input, i.e. deprecated configuration values
-- export
export logWarn = makeLogger("WARN", "\27[33m", {
    console:    true,
    file:       true
})

-- ::logError(string message, table options) -> void
-- Logs a message formatted as an ERROR message, used for user-faulted errors, i.e. misconfigured values
-- export
export logError = makeLogger("ERROR", "\27[31m", {
    console:    true,
    file:       true
})

-- ::logFatal(string message, table options) -> void
-- Logs a message formatted as a FATAL message, used for errors that would hamper normal operations, i.e. user-specified directory is a file
-- export
export logFatal = makeLogger("FATAL", "\27[35m", {
    console:    true,
    exit:       1,
    file:       true
})