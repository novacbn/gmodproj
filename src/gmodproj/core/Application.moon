import unpack from _G
import match from string
import remove from table

import existsSync, mkdirSync from require "fs"
import file, join from require "path"

import ConfigurationOptions from "gmodproj/api/ConfigurationOptions"
import Packager from "gmodproj/core/Packager"
import Resolver from "gmodproj/core/Resolver"
templates = dependency "gmodproj/core/templates"
import
    APPLICATION_CORE_VERSION, ENV_ALLOW_UNSAFE_SCRIPTING, PATH_DIRECTORY_CACHE, PATH_DIRECTORY_DATA,
    PATH_DIRECTORY_LOGS, PATH_DIRECTORY_PROJECT, PATH_FILE_MANIFEST, PATTERN_METADATA_NAME
from "gmodproj/lib/constants"
import ElapsedTimer from "gmodproj/lib/ElapsedTimer"
import exec, formatCommand, isDir, isFile from "gmodproj/lib/fsx"
import enableFileLogging, logInfo, logFatal from "gmodproj/lib/logging"
import ScriptingEnvironment from "gmodproj/lib/scripting"

-- ::TEXT_COMMAND_VERSION -> string
-- Represents the current version of the application
TEXT_COMMAND_VERSION = "#{APPLICATION_CORE_VERSION[1]}.#{APPLICATION_CORE_VERSION[2]}.#{APPLICATION_CORE_VERSION[3]} Pre-alpha"

-- ::TEXT_COMMAND_HELP -> string
-- Represents the help text of the application
TEXT_COMMAND_HELP = "Garry's Mod Project Manager :: #{TEXT_COMMAND_VERSION}

Syntax:     gmodproj [command]

Examples:   gmodproj build production
            gmodproj new addon novacbn my-addon
            gmodproj run prebuild

Commands:
    help                            Shows this help prompt
    new <template> <author> <name>  Creates a new directory for your project's with a template layout
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
            sourceDirectory:    "./src"

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

                buildDirectory: {is: "string"}
                sourceDirectory: {is: "string"}

                entryPoints: {
                    list_of: {
                        list_of: {is: "string"}
                    }
                },

                Packager: {"any_object"},
                Resolver: {"any_object"}
                Scripts: {"any_object"} -- TODO: string and function checks values in keypairs
            }
        }
    }

-- Application::Application()
-- Represents the console application frontend
export class Application
    -- Application::startupArguments -> table
    -- An array of arguments passed from the command line to the application
    startupArguments: nil

    -- Application::new(string ...)
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

    -- Application::configureEnvironment() -> void
    -- Configures the environment for project building
    configureEnvironment: () =>
        -- Create the directories needed for the build process
        mkdirSync(PATH_DIRECTORY_DATA) unless existsSync(PATH_DIRECTORY_DATA)
        mkdirSync(PATH_DIRECTORY_CACHE) unless existsSync(PATH_DIRECTORY_CACHE)
        mkdirSync(PATH_DIRECTORY_LOGS) unless existsSync(PATH_DIRECTORY_LOGS)

        -- Enable file logging
        enableFileLogging()

    -- Application::nextArgument() -> string or nil
    -- Pulls the next available argument from the startup arguments
    nextArgument: () =>
        return remove(@startupArguments, 1)

    -- Application::readManifest() -> ProjectOptions
    -- Reads the project's manifest file if available, otherwise uses all default values
    readManifest: () =>
        -- Validate the project's manifest then return the parsed contents
        logError("project.gmodproj must be a file!") if isDir(PATH_FILE_MANIFEST)
        return ProjectOptions\readFile(PATH_FILE_MANIFEST) if isFile(PATH_FILE_MANIFEST)
        return ProjectOptions({})

    -- Application::commandBuild() -> nil
    -- Starts building the project build output
    commandBuild: () =>
        -- Configure the application for building
        elapsedTimer = ElapsedTimer()
        @configureEnvironment()

        -- Parse the project manifest
        options = @readManifest()

        -- Retrieve the production mode of this build and cache options
        isProduction    = (@nextArgument() or "development")\lower() == "production"
        buildDirectory  = options\get("Project.buildDirectory")

        -- Require entry points for building
        entryPoints = options\get("Project.entryPoints")
        logFatal("Project has no entry points for building!") if #entryPoints < 1

        -- Make a new Resolver for assets
        resolver = Resolver(options\get("Project.sourceDirectory"), options\get("Project.Resolver"))

        -- Loop through each provided entry point to the package
        local packager
        for entryPoint in *entryPoints
            -- Make a new Packager for each build and write to the package
            logInfo("Building entry point '#{entryPoint[2]}'")
            packager = Packager(resolver, options\get("Project.Packager"))
            packager\writePackage(entryPoint[1], join(
                buildDirectory,
                entryPoint[2]..".lua"
            ), isProduction)

        -- Notify the user of completion time
        elapsedTime = elapsedTimer\getFormattedElapsed()
        logInfo("Build completed in #{elapsedTime}!")

    -- Application::commandNew() -> nil
    -- Creates a new project based off a template
    commandNew: () =>
        -- Retrieves the template for the project
        templateName    = @nextArgument()
        templateChunk   = templates[templateName]
        logFatal("Invalid template '#{templateName}'!") unless templateChunk

        -- Retrieve the author and name of the project
        projectAuthor = @nextArgument()
        unless projectAuthor and #projectAuthor > 0 and match(projectAuthor, PATTERN_METADATA_NAME)
            logFatal("Project name '#{projectAuthor}' is invalid, must be lowercase alphanumeric and dashes only!")

        projectName = @nextArgument()
        unless projectName and #projectName > 0 and match(projectName, PATTERN_METADATA_NAME)
            logFatal("Project name '#{projectName}' is invalid, must be lowercase alphanumeric and dashes only!")

        -- Validate the project's path and make the new directory
        projectPath = join(PATH_DIRECTORY_PROJECT, projectName)
        logFatal("Directory '#{projectName}' already exists!") if isDir(projectPath)
        mkdirSync(projectPath)

        -- Set up the environment of the template script and execute
        scriptingEnvironment = ScriptingEnvironment(projectPath, true)
        scriptingEnvironment\executeChunk(templateChunk, projectAuthor, projectName, projectPath, unpack(@startupArguments))
        logInfo("Successfully generated project at: #{projectPath}")

    -- Application::commandHelp() -> nil
    -- Displays the application's help text
    commandHelp: () => print(TEXT_COMMAND_HELP)

    -- Application:commandScript() -> void
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
            -- Set up a scripting environment for the script to execute in
            scriptingEnvironment            = ScriptingEnvironment(PATH_DIRECTORY_PROJECT, ENV_ALLOW_UNSAFE_SCRIPTING)
            success, bailedOut, message     = scriptingEnvironment\executeChunk(scriptContents, unpack(@startupArguments))

            -- Log the return message of the script
            unless success then logFatal(bailedOut or "Script #{scriptName} had an error!")
            elseif bailedOut == false then logFatal(message or "Script #{scriptName} failed to complete execution!")
            else logInfo(message or "Script #{scriptName} finished executing!")

    -- Application::commandVersion() -> void
    -- Displays the current version of the application
    commandVersion: () => print(TEXT_COMMAND_VERSION)
