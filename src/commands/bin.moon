import loadfile, print, type from _G

import process from _G
import readFileSync from require "fs"
import join from require "path"
import isfileSync from "novacbn/luvit-extras/fs"
moonscript = require "moonscript/base"

import ENV_ALLOW_UNSAFE_SCRIPTING, PROJECT_PATH, SYSTEM_OS_TYPE, SYSTEM_UNIX_LIKE from "novacbn/gmodproj/lib/constants"
import logError, logFatal, logInfo from "novacbn/gmodproj/lib/logging"
import ScriptingEnvironment from "novacbn/gmodproj/lib/ScriptingEnvironment"
import configureEnvironment, readManifest from "novacbn/gmodproj/lib/utilities"
import execFormat from "novacbn/gmodproj/lib/utilities/fs"

-- ::TEMPLATE_EXECUTION_SUCCESS(string script) -> string
-- Formats a successful script execution
--
TEMPLATE_EXECUTION_SUCCESS = (script) -> "Successfully executed '#{script}'"

-- ::TEMPLATE_EXECUTION_ERROR(string script) -> string
-- Formats failed script execution with an unexpected error
--
TEMPLATE_EXECUTION_ERROR = (script) -> "Unexpected error occured while executing '#{script}'"

-- ::TEMPLATE_EXECUTION_FAILED(string script, number status) -> string
-- Formats a failed script execution
--
TEMPLATE_EXECUTION_FAILED = (script, status) -> "Failed to execute '#{script}' (#{status})"

-- TEMPLATE_EXECUTION_SYNTAX(string script) -> string
-- Formats a failed script execution with a syntax error
--
TEMPLATE_EXECUTION_SYNTAX = (script) -> "Script '#{script}' had a syntax error"

-- ::resolveScript(string script) -> function?, function?
-- Resolves the script name to a executable script within the project's bin directory returning a loader function
--
-- Resolves with the following order:
--     * .moon  - Transpiles the script then loads it into gmodproj's runtime
--     * .lua   - Loads the script into gmodproj's runtime
--     * .sh    - (Linux/MacOS) Executes the Shell script using the OS' environment
--     * .bat   - (Windows) Executes the Batch script using the OS' environment
--
resolveScript = (script) ->
    scriptPath = join(PROJECT_PATH.bin, script)

    if isfileSync(scriptPath..".moon")
        return () -> moonscript.loadfile(scriptPath..".moon")
            

    elseif isfileSync(scriptPath..".lua")
        return () -> loadfile(scriptPath..".lua")

    elseif SYSTEM_UNIX_LIKE and isfileSync(scriptPath..".sh")
        return nil, (...) -> execFormat("/usr/bin/env", "sh", scriptPath..".sh", ...)

    elseif SYSTEM_OS_TYPE == "Windows" and isfileSync(scriptPath..".bat")
        return nil, (...) -> execFormat("cmd.exe", scriptPath..".bat", ...)

-- ::TEXT_COMMAND_DESCRIPTION -> string
-- Represents the description of the command
-- export
export TEXT_COMMAND_DESCRIPTION = "Executes a utility script from the project"

-- ::TEXT_COMMAND_SYNTAX -> string
-- Represents the syntax of the command
-- export
export TEXT_COMMAND_SYNTAX = "<script> [...args]"

-- ::TEXT_COMMAND_EXAMPLES -> string
-- Represents the examples of the command
-- export
export TEXT_COMMAND_EXAMPLES = {
    "build"
    "test"
}

-- ::executeCommand(Options options, string script, ...) -> void
-- Executes a specified script from the project's bin directory
-- export
export executeCommand = (options, script, ...) ->
    -- Configure the application's environment
    configureEnvironment()

    scriptLoader, shellLoader = resolveScript(script)
    if scriptLoader
        -- Load and check the specified script
        scriptChunk, err = scriptLoader()
        if err
            logError(err)
            logFatal(TEMPLATE_EXECUTION_SYNTAX(script))

        -- Set up an environment for the script to reside in
        scriptingEnvironment    = ScriptingEnvironment(PROJECT_PATH.home, ENV_ALLOW_UNSAFE_SCRIPTING)
        success, status, stdout = scriptingEnvironment\executeChunk(scriptChunk, ...)

        -- Fatally log if unsuccessful in execution
        if success
            if status == 0 then
                logInfo(stdout)

            else
                logError(stdout)
                logFatal(TEMPLATE_EXECUTION_FAILED(script, status), {exit: status})

        else
            logError(status)
            logFatal(TEMPLATE_EXECUTION_ERROR(script), {exit: -1})

    elseif shellLoader
        -- Only allow shell scripting if enabled
        if ENV_ALLOW_UNSAFE_SCRIPTING then
            -- Execute the shell script and check if successful
            success, status, stdout = shellLoader(...)
            if success then
                print(stdout)
                logInfo(TEMPLATE_EXECUTION_SUCCESS(script))

            else
                logError(stdout)
                logFatal(TEMPLATE_EXECUTION_FAILED(script, status), {exit: status})

        else logFatal("Unsafe scripting disabled by user!")

    else logFatal("Script '#{script}' not found!")