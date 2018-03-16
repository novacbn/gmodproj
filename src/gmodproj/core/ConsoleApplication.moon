import pcall, unpack from _G
import match from string
import remove from table

import existsSync, mkdirSync from require "fs"
import file, join from require "path"

import ConfigurationOptions from "gmodproj/api/ConfigurationOptions"
import Packager from "gmodproj/core/Packager"
import
    ENV_ALLOW_UNSAFE_SCRIPTING, PATH_DIRECTORY_CACHE, PATH_DIRECTORY_DATA, PATH_DIRECTORY_LOGS,
    PATH_DIRECTORY_PROJECT, PATH_FILE_MANIFEST
from "gmodproj/lib/constants"
import ElapsedTimer from "gmodproj/lib/ElapsedTimer"
import exec, formatCommand, isDir, isFile from "gmodproj/lib/fsx"
import enableFileLogging, logInfo, logFatal from "gmodproj/lib/logging"
import setEnvironment from "gmodproj/lib/scripting"

-- ::TEXT_COMMAND_VERSION -> string
-- Represents the current version of the application
TEXT_COMMAND_VERSION = "0.1.0 Pre-alpha"

-- ::TEXT_COMMAND_HELP -> string
-- Represents the help text of the application
TEXT_COMMAND_HELP = "Garry's Mod Project Manager :: #{TEXT_COMMAND_VERSION}

Syntax:     gmodproj [command]

Examples:   gmodproj build production
            gmodproj new addon my-project
            gmodproj run prebuild

Commands:
    help                            Shows this help prompt
    new <template> <name>           Creates a new directory for your project's with a template layout
                                        'addon', 'gamemode', 'package'

    build [mode]                    Builds your project into distributable Lua files
                                        (DEFAULT) 'development', 'production'
    script <script>                 Runs a specified script from your project manifest's 'Scripts'"

-- ProjectOptions::ProjectOptions()
-- Represents the configuration options of the application
class ProjectOptions extends ConfigurationOptions
    -- ProjectOptions::defaultConfiguration -> table
    -- Represents the default configuration values
    defaultConfiguration: {
        Project: {
            projectName:        "",
            projectAuthor:      "",

            buildDirectory:     "./dist",
            sourceDirectory:    "./src",
            entryPoints:        {},

            Packager: {},
            Scripts: {}
        }
    }

    -- ProjectOptions::configurationRules -> table
    -- Represents a LIVR ruleset for validating the configuration
    configurationRules: {
        Project: {
            nested_object: {
                projectName:    {is: "string"}, -- TODO: validate with pattern, alphanumeric and dashes only
                projectAuthor:  {is: "string"}, -- TODO: validate with pattern, alphanumeric and dashes only

                buildDirectory:     {is: "string"},
                sourceDirectory:    {is: "string"},

                entryPoints: {
                    list_of: {
                        list_of: {is: "string"}
                    }
                },

                Packager: {"any_object"},
                Scripts: {"any_object"} -- TODO: string and function checks values in keypairs
            }
        }
    }

-- ConsoleApplication::ConsoleApplication()
-- Represents the console application frontend
export class ConsoleApplication
    -- ConsoleApplication::startupArguments -> table
    -- An array of arguments passed from the command line to the application
    startupArguments: nil

    -- ConsoleApplication::templateMap -> table
    -- Name mapping for each project template type
    templateMap: {
        --package: require("templates/PackageTemplate").PackageTemplate
    }

    -- ConsoleApplication::new(string ...)
    -- Sets up the console application for use
    new: (...) =>
        -- Cache the startup commands and log to file
        @startupArguments = {...}
        logInfo("Application starting with: #{formatCommand('gmodproj', ...)}", true, false)

        -- Remap each command to their relevent method
        subCommand = @nextArgument()
        switch subCommand or "help"
            when "build" then @commandBuild()
            when "help" then @commandHelp()
            when "new" then @commandNew()
            when "script" then @commandScript()
            when "version" then @commandVersion()
            else logFatal("Invalid command '#{subCommand}'!")

    -- ConsoleApplication::configureEnvironment() -> void
    -- Configures the environment for project building
    configureEnvironment: () =>
        -- Create the directories needed for the build process
        mkdirSync(PATH_DIRECTORY_DATA) unless existsSync(PATH_DIRECTORY_DATA)
        mkdirSync(PATH_DIRECTORY_CACHE) unless existsSync(PATH_DIRECTORY_CACHE)
        mkdirSync(PATH_DIRECTORY_LOGS) unless existsSync(PATH_DIRECTORY_LOGS)

        -- Enable file logging
        enableFileLogging()

    -- ConsoleApplication::nextArgument() -> string or nil
    -- Pulls the next available argument from the startup arguments
    nextArgument: () =>
        return remove(@startupArguments, 1)

    -- ConsoleApplication::readManifest() -> ProjectOptions
    -- Reads the project's manifest file if available, otherwise uses all default values
    readManifest: () =>
        -- Validate the project's manifest then return the parsed contents
        logError("project.gmodproj must be a file!") if isDir(PATH_FILE_MANIFEST)
        return ProjectOptions\readFile(PATH_FILE_MANIFEST) if isFile(PATH_FILE_MANIFEST)
        return ProjectOptions({})

    -- ConsoleApplication::commandBuild() -> nil
    -- Starts building the project build output
    commandBuild: () =>
        -- Configure the application for building
        elapsedTimer = ElapsedTimer()
        @configureEnvironment()

        -- Parse the project manifest
        options = @readManifest()

        -- Retrieve the production mode of this build
        isProduction = (@nextArgument() or "development")\lower() == "production"

        -- Require entry points for building
        entryPoints = options\get("Project.entryPoints")
        logFatal("Project has no entry points for building!") if #entryPoints < 1

        -- Create the new packager and package up each entry point
        packager = Packager(options\get("Project.sourceDirectory"), options\get("Project.Packager"), "Project")
        for packageBuild in *entryPoints
            -- Write the package entry point and notify the user
            logInfo("Building entry point '#{packageBuild[2]}'")
            packager\writePackage(packageBuild, options\get("Project.buildDirectory"), isProduction)

        -- Notify the user of completion time
        elapsedTime = elapsedTimer\getFormattedElapsed()
        logInfo("Build completed in #{elapsedTime}!")

    -- ConsoleApplication::commandNew() -> nil
    -- Creates a new project based off a template
    commandNew: () =>
        -- Retrieves the template for the project
        templateName = @nextArgument()

        -- Try to import an internal template, otherwise an installed package
        success, template = tryImport("templates/#{templateName}", templateName)
        success, template = tryImport(templateName, file(templateName)) unless success

        -- If there is no template, bail on the user
        logFatal("Template '#{templateName}' could not be imported!") unless success

        -- Retrieve the name of the project
        projectName = @nextArgument()
        logFatal("Project name '#{projectName}' is invalid, must be lowercase letters and dashes only!") unless match(projectName, "^[%l%-]+$")

        -- Concat the new project's path and check if it exists
        projectPath = join(PATH_DIRECTORY_PROJECT, projectName)
        logFatal("Project directory '#{projectName}' already exists!") if isDir(projectPath)

        -- Create a new project with the template
        projectTemplate = template\new(projectName, projectPath)
        projectTemplate\generate()

        logInfo("Successfully generated project at: #{projectPath}")

    -- ConsoleApplication::commandHelp() -> nil
    -- Displays the application's help text
    commandHelp: () => print(TEXT_COMMAND_HELP)

    -- ConsoleApplication:commandScript() -> void
    -- Runs a specified script from the project's manifest
    commandScript: () =>
        -- Configure the application's environment
        @configureEnvironment()

        -- Get the specified script and assert validity
        scriptName = @nextArgument()
        logFatal("Must specifiy a script to run!") unless scriptName

        options = @readManifest()
        scriptContents = options\get("Project.Scripts.#{scriptName}")
        logFatal("Script '#{scriptName}' is invalid!") unless scriptContents

        -- Run the script as a shell command if it is a string
        if type(scriptContents) == "string" then
            -- Check if unsafe scripting is allowed
            if ENV_ALLOW_UNSAFE_SCRIPTING
                -- Execute the command, format message based on execution success
                message, status = exec(scriptContents)
                if status == 0 then logInfo("Successfully executed '#{scriptContents}':\n#{message}")
                else logFatal("Could not execute '#{scriptContents}: (#{status})\n#{message}'")

            -- Alert that unsafe scripting was disabled and bail
            else logFatal("Unsafe scripting disabled by user!")

        else
            -- Set the environment of the script function before running
            scriptChunk         = setEnvironment(scriptContents)
            success, message    = scriptChunk(unpack(@startupArguments))

            -- Log the return message of the script
            if success == false then logFatal(message or "Script #{scriptName} failed to complete execution!")
            elseif success == true then logInfo(message or "Script #{scriptName} finished executing!")

    -- ConsoleApplication::commandVersion() -> void
    -- Displays the current version of the application
    commandVersion: () => print(TEXT_COMMAND_VERSION)
