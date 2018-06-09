import loadfile, print, type from _G

import process from _G
import readFileSync from require "fs"
import join from require "path"
moonscript = require "moonscript/base"

import ENV_ALLOW_UNSAFE_SCRIPTING, PROJECT_PATH, SYSTEM_OS_TYPE, SYSTEM_UNIX_LIKE from "novacbn/gmodproj/lib/constants"
import logError, logFatal, logInfo from "novacbn/gmodproj/lib/logging"
import ScriptingEnvironment from "novacbn/gmodproj/lib/ScriptingEnvironment"
import configureEnvironment, readManifest from "novacbn/gmodproj/lib/utilities"
import execFormat, isFile from "novacbn/gmodproj/lib/utilities/fs"

-- ::TEMPLATE_EXECUTION_SUCCESS(string script, number status) -> string
-- Formats a successful script execution
--
TEMPLATE_EXECUTION_SUCCESS = (script, status) -> "Successfully executed '#{script}' (#{status})"

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

    if isFile(scriptPath..".moon")
        return () -> moonscript.loadfile(scriptPath..".moon")
            

    elseif isFile(scriptPath..".lua")
        return () -> loadfile(scriptPath..".lua")

    elseif SYSTEM_UNIX_LIKE and isFile(scriptPath..".sh")
        return nil, (...) -> execFormat("/usr/bin/env", "sh", scriptPath..".sh", ...)

    elseif SYSTEM_OS_TYPE == "Windows" and isFile(scriptPath..".bat")
        return nil, (...) -> execFormat("cmd.exe", scriptPath..".bat", ...)


-- ::formatDescription(table flags) -> string
-- Formats the help description of the command
-- export
export formatDescription = (flags) ->
    return "bin <script>\t\t\t\tExecutes a utility script located in your project's 'bin' directory"

-- ::executeCommand(table flags, string script, ...) -> void
-- Executes a specified script from the project's bin directory
-- export
export executeCommand = (flags, script, ...) ->
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
                logInfo(TEMPLATE_EXECUTION_SUCCESS(script, status), {exit: status})

            else
                logError(stdout)
                logFatal(TEMPLATE_EXECUTION_FAILED(script, status), {exit: status})

        else logFatal("Unsafe scripting disabled by user!")

    else logFatal("Script '#{script}' not found!")