import loadstring, print, type from _G
import os from jit

import process from _G
import readFileSync from require "fs"
import join from require "path"
moonscript = require "moonscript/base"

import ENV_ALLOW_UNSAFE_SCRIPTING, PROJECT_PATH from "novacbn/gmodproj/lib/constants"
import logFatal, logInfo from "novacbn/gmodproj/lib/logging"
import ScriptingEnvironment from "novacbn/gmodproj/lib/ScriptingEnvironment"
import configureEnvironment, readManifest from "novacbn/gmodproj/lib/utilities"
import execFormat, isFile from "novacbn/gmodproj/lib/utilities/fs"

-- ::TEMPLATE_EXECUTION_SUCCESS(string script, number status, string stdout) -> string
-- Formats a successful script execution string
--
TEMPLATE_EXECUTION_SUCCESS = (script, status, stdout) -> "#{stdout}

Successfully executed '#{script}' (#{status})"

-- ::TEMPLATE_EXECUTION_FAILED(string script, number status, string stdout) -> string
-- Formats a unsuccessful script execution string
--
TEMPLATE_EXECUTION_FAILED = (script, status, stdout) -> "#{stdout}

Failed to execute '#{script}' (#{status})"

-- ::resolveScript(string script) -> function?, function?
-- Resolves the script name to a executable script within the project's bin directory returning a loader function
--
-- Resolves with the following order:
--     * .moon  - Transpiles the script then loads it into gmodproj's runtime
--     * .lua   - Loads the script into gmodproj's runtime
--     * .sh    - (Linux) Executes the Shell script using the OS' environment
--     * .bat   - (Windows) Executes the Batch script using the OS' environment
--
resolveScript = (script) ->
    scriptPath = join(PROJECT_PATH.bin, script)

    if isFile(scriptPath..".moon")
        return () ->
            contents = readFileSync(scriptPath..".moon")
            return moonscript.loadstring(contents, scriptPath..".moon")
            

    elseif isFile(scriptPath..".lua")
        return () ->
            contents = readFileSync(scriptPath..".lua")
            return loadstring(contents, scriptPath..".lua")

    elseif os == "Linux" and isFile(scriptPath..".sh")
        return nil, (...) -> execFormat(scriptPath..".sh", ...)

    elseif os == "Windows" and isFile(scriptPath..".bat")
        return nil, (...) -> execFormat(scriptPath..".bat", ...)


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
        logFatal("Script '#{script}' had a syntax error:\n#{err}") if err

        -- Set up an environment for the script to reside in
        scriptingEnvironment    = ScriptingEnvironment(PROJECT_PATH.home, ENV_ALLOW_UNSAFE_SCRIPTING)
        success, status, stdout = scriptingEnvironment\executeChunk(scriptChunk, ...)

        -- Fatally log if unsuccessful in execution
        if success
            print(stdout)
            process\exit(status)

        else logFatal(TEMPLATE_EXECUTION_FAILED(script, status, stdout), {exit: status})

    elseif shellFunc
        -- Only allow shell scripting if enabled
        if ENV_ALLOW_UNSAFE_SCRIPTING then
            -- Execute the shell script and check if successful
            success, status, stdout = shellFunc(...)
            if success then logInfo(TEMPLATE_EXECUTION_SUCCESS(script, status, stdout), {exit: status})
            else logFatal(TEMPLATE_EXECUTION_FAILED(script, status, stdout), {exit: status})

        else logFatal("Unsafe scripting disabled by user!")

    else logFatal("Script '#{script}' not found!")