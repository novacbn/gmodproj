import lower from string

import join from require "path"
import isdirSync from "novacbn/luvit-extras/fs"

import Packager from "novacbn/gmodproj/Packager"
import PluginManager from "novacbn/gmodproj/PluginManager"
import Resolver from "novacbn/gmodproj/Resolver"
import PROJECT_PATH from "novacbn/gmodproj/lib/constants"
import ElapsedTimer from "novacbn/gmodproj/lib/ElapsedTimer"
import logFatal, logInfo from "novacbn/gmodproj/lib/logging"
import configureEnvironment, readManifest from "novacbn/gmodproj/lib/utilities"

-- ::TEXT_COMMAND_DESCRIPTION -> string
-- Represents the description of the command
-- export
export TEXT_COMMAND_DESCRIPTION = "Builds the project into distributable files"

-- ::TEXT_COMMAND_SYNTAX -> string
-- Represents the syntax of the command
-- export
export TEXT_COMMAND_SYNTAX = "[mode]"

-- ::TEXT_COMMAND_EXAMPLES -> string
-- Represents the examples of the command
-- export
export TEXT_COMMAND_EXAMPLES = {
    "development"
    "production"
}

-- ::configureCommand(Options options) -> void
-- Configures the input of the command
-- export
export configureCommand = (options) ->
    with options
        \boolean "no-cache", "Disables caching of built project files"
        \boolean "no-logs", "Disables logging to files"
        \boolean "quiet", "Disables logging to console"

-- ::executeCommand(Options options, string mode?) -> void
-- Builds the project found in the current working directory
-- export
export executeCommand = (options, mode="development") ->
    -- Configure the application environment for building
    configureEnvironment()
    elapsedTimer    = ElapsedTimer\new()
    manifest        = readManifest()

    -- Make and configure new Resolver and Packager for building
    pluginManager   = PluginManager\new(manifest\get("Plugins"))
    resolver        = Resolver\new(
        manifest\get("author"),
        manifest\get("name"),
        manifest\get("sourceDirectory"),
        pluginManager, manifest\get("Resolver")
    )

    packager = Packager\new(lower(mode) == "production", options, resolver, pluginManager, manifest\get("Packager"))

    -- Build a distributable package for each specified project build
    buildDirectory = join(PROJECT_PATH.home, manifest\get("buildDirectory"))
    logFatal("Build directory does not exist!") unless isdirSync(buildDirectory)

    for entryPoint, targetPackage in pairs(manifest\get("projectBuilds"))
        logInfo("Building entry point '#{entryPoint}'")
        packager\writePackage(entryPoint, join(
            buildDirectory,
            targetPackage..".lua"
        ))

    -- Notify the user of completion time
    elapsedTime = elapsedTimer\getFormattedElapsed()
    logInfo("Build completed in #{elapsedTime}!")