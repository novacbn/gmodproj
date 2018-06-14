import print, tonumber from _G
import wrap from coroutine
import match from string

import writeFileSync from require "fs"
import basename, join from require "path"
import readLine from require "readline"
import encode from "novacbn/properties/exports"

import PROJECT_PATH from "novacbn/gmodproj/lib/constants"
import makeSync from "novacbn/gmodproj/lib/utilities"
import PATTERN_METADATA_NAME, PATTERN_METADATA_REPOSITORY, PATTERN_METADATA_VERSION from "novacbn/gmodproj/schemas/ProjectOptions"

-- ::PATTERN_MODULE_NAMESPACE -> string
-- Represents a pattern to validate module namespaces
--
PATTERN_MODULE_NAMESPACE = "^[%w/%-_]+$"

-- ::readLineSync() -> string
-- 
--
readLineSync = makeSync(readLine)

-- ::prompt(string question, function callback, string default?) -> string
-- Prompts the user for input to a question
--
local prompt
prompt = (question, default) ->
    err, answer = readLineSync(default and "#{question} (#{default}): " or "#{question}: ")

    if default then return answer == "" and default or answer
    elseif answer == "" then return prompt(question)
    else return answer

-- ::validatedPrompt(string question, function check, string err, function callback, string default?) -> string
-- Re-prompts the user with an error message if the check function does not pass
--
validatedPrompt = (question, check, err, default) ->
    local answer
    while answer == nil
        answer = prompt(question, default)
        unless check(answer)
            print("\27[31merr:\27[0m "..err)
            answer = nil

    return answer

-- ::formatDescription() -> string
-- Formats the help description of the command
-- export
export formatDescription = () ->
    return "init\t\t\t\t\tInitializes an already existing project to work with gmodproj"

-- ::executeCommand(table flags) -> void
-- Initializes the current working directory as a gmodproj project
-- export
export executeCommand = wrap((flags) ->
    -- Prompt the user for project metadata
    directoryName   = basename(PROJECT_PATH.home)
    projectName     = validatedPrompt(
        "Project name",
        => match(@, PATTERN_METADATA_NAME),
        "must start with a letter and contain only lowercase alphanumerical characters and dashes",
        match(directoryName, PATTERN_METADATA_NAME) and directoryName
    )

    projectAuthor = validatedPrompt(
        "Project author",
        => match(@, PATTERN_METADATA_NAME),
        "must start with a letter and contain only lowercase alphanumerical characters and dashes"
    )

    projectVersion = validatedPrompt(
        "Project version",
        => match(@, PATTERN_METADATA_VERSION),
        "must be formatted as 'NUMBER.NUMBER.NUMBER'",
        "1.0.0"
    )

    projectRepository = validatedPrompt(
        "Project repository",
        => match(@, PATTERN_METADATA_REPOSITORY),
        "must be formatted as 'PROTOCOL://PATH'",
        "unknown://unknown"
    )

    entryPoints = tonumber(validatedPrompt(
        "Amount of project entry points",
        => tonumber(@) > 0,
        "must have at least one entry point",
        "1"
    ))

    -- Prompt the user for project entry points
    local entryPoint, endPoint
    projectBuilds = {}
    for index=1, entryPoints
        entryPoint = validatedPrompt(
            "Entry point ##{index}",
            => match(@, PATTERN_MODULE_NAMESPACE),
            "namespace must contain only alphanumeric characters, dashes, slashes, and underscores",
            "main"
        )

        endPoint                    = prompt("End point ##{index}", "#{projectAuthor}.#{projectName}.#{basename(entryPoint)}")
        projectBuilds[entryPoint]   = endPoint


    -- Write the generated manifest to the project directory
    encoded = encode({
        name:       projectName
        author:     projectAuthor
        version:    projectVersion
        repository: projectRepository

        projectBuilds: projectBuilds
    }, {propertiesEncoder: "moonscript"})

    writeFileSync(join(PROJECT_PATH.home, ".gmodmanifest"), encoded)
)