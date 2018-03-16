import mkdir from require "fs"

import serializeTable from require "utilities"
import logInfo from require "utilities.logging"
import Object from require "utilities.Object"
import join, write from require "utilities.shell"

-- Template::Template()
-- Represents a generic project template generator
Template = Object
    -- Template::constructor(string projectName, string projectPath)
    -- Sets up a project template generator before generation
    constructor: (projectName, projectPath) =>
        -- Create the project directory
        mkdir(projectPath)

        -- Cache the project's directory name and path
        @projectName    = projectName
        @projectPath    = projectPath

    -- Template::createDirectory(string directoryName) -> nil
    -- Creates a directory within the project's directory
    createDirectory: (directoryName) =>
        -- Join the directory name and create it
        path = join(@projectPath, directoryName)
        mkdir(path)

    -- Template::createFile(string fileName, string contents) ->
    -- Creates a file within the project's directory with the contents
    createFile: (fileName, contents) =>
        -- Join the file name to the project's path and save the contents
        path = join(@projectPath, fileName)
        write(path, contents)

        -- Log the file creation
        logInfo("Created template file at '#{fileName}'")

    -- Template::createManifest(string fileName, table data) -> nil
    -- Creates encodes data to the TOML format and saves within the project's directory
    createManifest: (fileName, data) =>
        -- Encode the data to the file
        @createFile(fileName, serializeTable(data))

    generate: () => error("method 'generate' not implemented")

return :Template