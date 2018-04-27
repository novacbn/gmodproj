
import dirname, join from require "path"
import existsSync, mkdirSync, writeFileSync from require "fs"
import encode from require "json"

import Object from "novacbn/novautils/utilities/Object"

import isDir from "novacbn/gmodproj/lib/fsx"
import toString from "novacbn/gmodproj/lib/datafile"

-- Template::Template()
-- Represents a template for quickly creating new project directory structures
-- export
export Template = Object\extend {
    -- Template::projectAuthor -> string
    -- Represents the author of the project
    --
    projectAuthor: nil

    -- Template::projectName -> string
    -- Represents the name of the project
    --
    projectName: nil

    -- Template::projectPath -> string
    -- Represents the base directory of the project
    --
    projectPath: nil

    -- Template::constructor(string projectPath, string projectAuthor, string projectName)
    -- Constructor for Template
    --
    constructor: (@projectPath, @projectAuthor, @projectName) =>

    -- Template::createDirectory(string directoryPath) -> void
    -- Creates a new directory within the new project directory
    --
    createDirectory: (directoryPath) =>
        -- Validate the path can be created then make it
        directoryPath = join(@projectPath, directoryPath)
        error("bad argument #1 to 'createDirectory' (path already exists)") if existsSync(directoryPath)
        error("bad argument #1 to 'createDirectory' (parent directory does not exist)") unless isDir(dirname(directoryPath))
        mkdirSync(directoryPath)

    -- Template::write(string filePath, string fileContents) -> void
    -- Writes the file contents to the specified file within the new project directory
    --
    write: (filePath, fileContents) =>
        filePath = join(@projectPath, filePath)
        error("bad argument #1 to 'write' (parent directory does not exist)") unless isDir(dirname(filePath))
        writeFileSync(filePath, fileContents)

    -- Template::writeDataFile(string filePath, table sourceTable) -> void
    -- Encodes and writes the source table to the specified file within the new project directory using DataFile encoding
    --
    writeDataFile: (filePath, sourceTable) =>
        @write(filePath, toString(sourceTable))

    writeJSON: (filePath, sourceTable) =>
        @write(filePath, encode(sourceTable))

    -- Template::createProject(string ...) -> void
    -- Event called to construct the new project, providing any extra arguments specified by the user
    -- event
    createProject: (...) =>
}