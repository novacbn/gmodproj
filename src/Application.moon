import unpack from _G
import lower, match from string
import concat, insert, remove, sort from table

import existsSync, mkdirSync, readFileSync from require "fs"
import join from require "path"

import Default, Object from "novacbn/novautils/utilities/Object"

import Packager from "novacbn/gmodproj/Packager"
import PluginManager from "novacbn/gmodproj/PluginManager"
import Resolver from "novacbn/gmodproj/Resolver"
import PATTERN_METADATA_NAME, ProjectOptions from "novacbn/gmodproj/schemas/ProjectOptions"

import APPLICATION_CORE_VERSION, ENV_ALLOW_UNSAFE_SCRIPTING, MAP_DEFAULT_PLUGINS, PROJECT_PATH from "novacbn/gmodproj/lib/constants"
import fromString from "novacbn/gmodproj/lib/datafile"
import ElapsedTimer from "novacbn/gmodproj/lib/ElapsedTimer"
import exec, formatCommand, isDir, isFile from "novacbn/gmodproj/lib/fsx"
import enableFileLogging, logInfo, logError, logFatal, toggleConsoleLogging, toggleFileLogging from "novacbn/gmodproj/lib/logging"
import ScriptingEnvironment from "novacbn/gmodproj/lib/ScriptingEnvironment"

-- ::PATTERN_FLAG_MINI -> string
-- Represents a Lua pattern to determine if the string is a mini command flag
--
PATTERN_FLAG_MINI = "%-[%w%-]+"

-- ::PATTERN_FLAG_FULL -> string
-- Represents a Lua pattern to determine if the string is a full command flag
--
PATTERN_FLAG_FULL = "%-%-[%w%-]+"

-- ::TEXT_COMMAND_VERSION -> string
-- Represents the current version of the application
--
TEXT_COMMAND_VERSION = "#{APPLICATION_CORE_VERSION[1]}.#{APPLICATION_CORE_VERSION[2]}.#{APPLICATION_CORE_VERSION[3]} Pre-alpha"

-- ::TEMPLATE_COMMAND_HELP(string templateNames) -> string
-- Represents the help text of the application
--
TEMPLATE_COMMAND_HELP = (templateNames) -> "Garry's Mod Project Manager :: #{TEXT_COMMAND_VERSION}
Syntax:     gmodproj [flags] [command]

Examples:   gmodproj build production
            gmodproj new addon novacbn my-addon
            gmodproj script prebuild

Commands:
    help                            Shows this help prompt
    new <template> <author> <name>  Creates a new directory for your project's with a template layout
                                        #{templateNames}

    build [mode]                    Builds your project into distributable Lua files
                                        (DEFAULT) 'development', 'production'
    script <script>                 Runs a specified script from your project manifest's 'Scripts'

Flags:
    -q, --quiet         Disables all logging to console
    -nf, --no-file      Disables all logging to files
    -nc, --no-cache     Disables the build cache"

-- ::configureEnvironment(table flags) -> void
-- Configures the project's directory environment
--
configureEnvironment = (flags) ->
    -- Create the directories needed
    mkdirSync(PROJECT_PATH.data) unless isDir(PROJECT_PATH.data)
    mkdirSync(PROJECT_PATH.cache) unless isDir(PROJECT_PATH.cache)
    mkdirSync(PROJECT_PATH.plugins) unless isDir(PROJECT_PATH.plugins)
    mkdirSync(PROJECT_PATH.logs) unless isDir(PROJECT_PATH.logs)

    -- Enable file logging if allowed
    enableFileLogging() unless flags["-nf"] or flags["-no-file"]

-- ::extractFlags(string ...) -> table, table
-- Extracts the command flags from the command arguments
--
extractFlags = (...) ->
    varargs = {...}

    commands, flags = {}, {}
    for argument in *varargs
        if match(argument, PATTERN_FLAG_MINI) or match(argument, PATTERN_FLAG_FULL)
            flags[lower(argument)] = true

        else insert(commands, argument)

    return flags, commands

-- ::readManifest() -> table
-- Reads the project's manifest file, fatally exits process on errors
--
readManifest = () ->
    -- Read the project's manifest file if it exists
    logFatal("Failed to read manifest.gmodproj, is a directory!") if isDir(PROJECT_PATH.manifest)
    options = {}
    options = fromString(readFileSync(PROJECT_PATH.manifest)) if isFile(PROJECT_PATH.manifest)

    -- Validate the project's manifest, alerting users to any validation errors
    success, err = pcall(ProjectOptions.new, ProjectOptions, options)
    unless success
        logError(err)
        logFatal("Failed to validate manifest.gmodproj!")

    return err

-- Application::Application()
-- Represents the console application frontend
-- export
export Application = Object\extend {
    -- Application::registeredTemplates -> table
    -- Represents the project templates registered with the Application
    --
    registeredTemplates: Default {}

    -- Application::constructor(string ...)
    -- Constructor for Application
    --
    constructor: (...) =>
        -- Extract the command flags from the sub commands
        flags, commands = extractFlags(...)
        subCommand      = remove(commands, 1)

        -- Disable relevent loggers
        toggleConsoleLogging(not (flags["-q"] or flags["--quiet"]))
        toggleFileLogging(not (flags["-nf"] or flags["--no-file"]))

        -- Log to file the arguments used to start the application
        logInfo("Application starting with: #{formatCommand('gmodproj', ...)}", {
            console:    false
            file:       true
        })

        -- Retrieve the method used by the specified sub command
        commandMethod = switch subCommand or "help"
            when "build" then @commandBuild
            when "help" then @commandHelp
            when "new" then @commandNew
            when "script" then @commandScript
            when "version" then @commandVersion

        logFatal("Invalid command '#{subCommand}'!") unless commandMethod
        commandMethod(self, flags, unpack(commands))

    -- Application::registerTemplate(string templateName, Template template) -> void
    -- Registers a project template with the Application
    --
    registerTemplate: (templateName, template) =>
        -- TODO: type check
        @registeredTemplates[templateName] = template

    -- Application::commandBuild(table flags, string buildMode?) -> void
    -- Builds the project with the provided configuration from the manifest
    -- event
    commandBuild: (flags, buildMode="development") =>
        -- Configure the application for building
        configureEnvironment(flags)
        elapsedTimer    = ElapsedTimer\new()
        options         = readManifest()

        -- Make and configure new Resolver and Packager for building
        pluginManager   = PluginManager\new(options\get("Project.Plugins"))
        resolver        = Resolver\new(
            options\get("Project.projectAuthor"),
            options\get("Project.projectName"),
            options\get("Project.sourceDirectory"),
            pluginManager, options\get("Project.Resolver")
        )

        packager = Packager\new(lower(buildMode) == "production", flags, resolver, pluginManager, options\get("Project.Packager"))

        -- Build a distributable package for each specified entry point
        buildDirectory = join(PROJECT_PATH.home, options\get("Project.buildDirectory"))
        for entryPoint in *options\get("Project.entryPoints")
            logInfo("Building entry point '#{entryPoint[2]}'")
            packager\writePackage(entryPoint[1], join(
                buildDirectory,
                entryPoint[2]..".lua"
            ))

        -- Notify the user of completion time
        elapsedTime = elapsedTimer\getFormattedElapsed()
        logInfo("Build completed in #{elapsedTime}!")

    -- Application::commandNew(table flags, string templateName, string projectAuthor, string projectName, string ...) -> void
    -- Creates a new project based on a registered template
    -- event
    commandNew: (flags, templateName, projectAuthor, projectName, ...) =>
        -- Load the default plugins and register their templates
        pluginManager = PluginManager\new(MAP_DEFAULT_PLUGINS)
        pluginManager\dispatchEvent("registerTemplates", self)

        -- Retrieve the template and validate the project information
        template = @registeredTemplates[templateName]
        logFatal("Invalid template '#{templateName}'!") unless template

        unless projectAuthor and #projectAuthor > 0 and match(projectAuthor, PATTERN_METADATA_NAME)
            logFatal("Project author #{projectAuthor} is invalid, must be lowercase alphanumeric and dashes only!")

        unless projectName and #projectName > 0 and match(projectName, PATTERN_METADATA_NAME)
            logFatal("Project name #{projectName} is invalid, must be lowercase alphanumeric and dashes only!")

        -- Validate and create the new project directory
        projectPath = join(PROJECT_PATH.home, projectName)
        logFatal("Path '#{projectName}' is already a file or directory!") if existsSync(projectPath)
        mkdirSync(projectPath)

        -- Create the new project
        loadedTemplate = template\new(projectPath, projectAuthor, projectName)
        loadedTemplate\createProject(...)
        logInfo("Successfully generated project at: #{projectPath}")

    -- Application::commandHelp(table flags) -> void
    -- Displays the application's help text
    -- event
    commandHelp: (flags) =>
        -- Load the default plugins and register their templates
        pluginManager = PluginManager\new(MAP_DEFAULT_PLUGINS)
        pluginManager\dispatchEvent("registerTemplates", self)

        -- Format the registered templates into a friendly display string
        templateNames = ["'"..templateName.."'" for templateName, template in pairs(@registeredTemplates)]
        sort(templateNames)
        templateNames = concat(templateNames, ", ")

        -- Format and display the help text of the application
        print(TEMPLATE_COMMAND_HELP(templateNames))

    -- Application:commandScript(table flags, string scriptName, string ...) -> void
    -- Runs a specified script from the project's manifest
    -- event
    commandScript: (flags, scriptName, ...) =>
        -- Configure the application's environment
        configureEnvironment(flags)

        -- Validate the specified script
        logFatal("Must specifiy a script to run!") unless scriptName
        options         = readManifest()
        scriptContents  = options\get("Project.Scripts.#{scriptName}")
        logFatal("Script '#{scriptName}' is invalid!") unless scriptContents

        -- Run the script as a shell command if it is a string
        if type(scriptContents) == "string" then
            -- Check if unsafe scripting is allowed
            if ENV_ALLOW_UNSAFE_SCRIPTING
                -- Execute the command, format message based on execution success
                success, status, stdout = exec(scriptContents)
                if success then logInfo("Successfully executed '#{scriptContents}': (#{status})\n#{stdout}")
                else logFatal("Could not execute '#{scriptContents}': (#{status})\n#{stdout}'")

            -- Alert that unsafe scripting was disabled and bail
            else logFatal("Unsafe scripting disabled by user!")

        else
            -- Set up a scripting environment for the script to execute in
            scriptingEnvironment        = ScriptingEnvironment(PROJECT_PATH.home, ENV_ALLOW_UNSAFE_SCRIPTING)
            success, status, message    = scriptingEnvironment\executeChunk(scriptContents, ...)

            -- Log the return message of the script
            unless success then logFatal("Script #{scriptName} had an error:\n#{status}")
            elseif status ~= 0 then logFatal(message or "Script #{scriptName} failed to complete execution!", nil, nil, status)
            else logInfo(message or "Script #{scriptName} finished executing!")

    -- Application::commandVersion(table flags) -> void
    -- Displays the current version of the application
    -- event
    commandVersion: (flags) => print(TEXT_COMMAND_VERSION)
}