import lower from string

import join from require "path"

import Packager from "novacbn/gmodproj/Packager"
import PluginManager from "novacbn/gmodproj/PluginManager"
import Resolver from "novacbn/gmodproj/Resolver"
import PROJECT_PATH from "novacbn/gmodproj/lib/constants"
import ElapsedTimer from "novacbn/gmodproj/lib/ElapsedTimer"
import logFatal, logInfo from "novacbn/gmodproj/lib/logging"
import configureEnvironment, readManifest from "novacbn/gmodproj/lib/utilities"
import isDir from "novacbn/gmodproj/lib/utilities/fs"

-- ::formatDescription(table flags) -> string
-- Formats the help description of the command
-- export
export formatDescription = (flags) ->
    return "build [mode]\t\t\t\tBuilds your project into distributable Lua files\n\t\t\t\t\t\t\t(DEFAULT) 'development', 'production'"

-- ::executeCommand(table flags, string mode?) -> void
-- Builds the project found in the current working directory
-- export
export executeCommand = (flags, mode="development") ->
    -- Configure the application environment for building
    configureEnvironment()
    elapsedTimer    = ElapsedTimer\new()
    options         = readManifest()

    -- Make and configure new Resolver and Packager for building
    pluginManager   = PluginManager\new(options\get("Plugins"))
    resolver        = Resolver\new(
        options\get("author"),
        options\get("name"),
        options\get("sourceDirectory"),
        pluginManager, options\get("Resolver")
    )

    packager = Packager\new(lower(mode) == "production", flags, resolver, pluginManager, options\get("Packager"))

    -- Build a distributable package for each specified project build
    buildDirectory = join(PROJECT_PATH.home, options\get("buildDirectory"))
    logFatal("Build directory does not exist!") unless isDir(buildDirectory)

    for entryPoint, targetPackage in pairs(options\get("projectBuilds"))
        logInfo("Building entry point '#{entryPoint}'")
        packager\writePackage(entryPoint, join(
            buildDirectory,
            targetPackage..".lua"
        ))

    -- Notify the user of completion time
    elapsedTime = elapsedTimer\getFormattedElapsed()
    logInfo("Build completed in #{elapsedTime}!")