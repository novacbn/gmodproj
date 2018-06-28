import pairs, type from _G
import match from string
import concat, sort from table

import existsSync, mkdirSync from require "fs"
import join from require "path"
import hasInherited from "novacbn/novautils/utilities/Object"

import PluginManager from "novacbn/gmodproj/PluginManager"
import Template from "novacbn/gmodproj/api/Template"
import MAP_DEFAULT_PLUGINS, PROJECT_PATH from "novacbn/gmodproj/lib/constants"
import logFatal, logInfo from "novacbn/gmodproj/lib/logging"
import PATTERN_METADATA_NAME from "novacbn/gmodproj/schemas/ProjectOptions"

-- TemplateRegister::TemplateRegister()
-- Represents a primitive allowing plugins to register project templates
--
TemplateRegister = () -> {
    -- TemplateRegister::registeredTemplates -> table
    -- Represents the project templates registered via plugins
    --
    registeredTemplates: {}

    -- TemplateRegister::registerTemplate(string name, Template template) -> void
    -- Registers a project template with from a plugin
    --
    registerTemplate: (name, template) =>
        error("bad argument #1 to 'registerTemplate' (expected string value)") unless type(name) == "string"
        error("bad argument #1 to 'registerTemplate' (template name already registered)") if @registeredTemplates[name]
        error("bad argument #2 to 'registerTemplate' (expected Template value)") unless type(template) == "table" and hasInherited(Template, template)

        @registeredTemplates[name] = template
}

-- ::TEXT_COMMAND_DESCRIPTION -> string
-- Represents the description of the command
-- export
export TEXT_COMMAND_DESCRIPTION = "Initializes a new project using a project template"

-- ::TEXT_COMMAND_SYNTAX -> string
-- Represents the syntax of the command
-- export
export TEXT_COMMAND_SYNTAX = "<template> <author> <name>"

-- ::TEXT_COMMAND_EXAMPLES -> string
-- Represents the examples of the command
-- export
export TEXT_COMMAND_EXAMPLES = {
    "addon novacbn my-addon"
    "gamemode novacbn my-gamemode"
    "package novacbn package"
}

-- ::executeCommand(Options options, string template, string author, string name, string ...) -> void
-- Creates the new project directory under the current working directory
-- export
export executeCommand = (options, templateName, author, name, ...) ->
    -- Load the default plugins and register their templates
    templateRegister    = TemplateRegister()
    pluginManager       = PluginManager\new(MAP_DEFAULT_PLUGINS)
    pluginManager\dispatchEvent("registerTemplates", templateRegister)

    -- Retrieve the template and validate the project information
    template = templateRegister.registeredTemplates[templateName]
    logFatal("Invalid template '#{templateName}'!") unless template

    unless author and #author > 0 and match(author, PATTERN_METADATA_NAME)
        logFatal("Project author #{author} is invalid, must be lowercase alphanumeric and dashes only!")

    unless name and #name > 0 and match(name, PATTERN_METADATA_NAME)
        logFatal("Project name #{name} is invalid, must be lowercase alphanumeric and dashes only!")

    -- Validate and create the new project directory
    projectPath = join(PROJECT_PATH.home, name)
    logFatal("Path '#{name}' is already exists!") if existsSync(projectPath)
    mkdirSync(projectPath)

    -- Create the new project
    loadedTemplate = template\new(projectPath, author, name)
    loadedTemplate\createProject(...)
    logInfo("Successfully generated project at: #{projectPath}")