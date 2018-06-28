import unlinkSync from require "fs"
import join from require "path"
import isdirSync, isfileSync, walkSync from "novacbn/luvit-extras/fs"

import PROJECT_PATH from "novacbn/gmodproj/lib/constants"
import logInfo from "novacbn/gmodproj/lib/logging"

-- ::cleanDirectory(string directory) -> void
-- Removes all files within the specified directory
--
cleanDirectory = (directory) ->
    for file in *walkSync(directory)
        unlinkSync(file) if isfileSync(file)

-- ::TEXT_COMMAND_DESCRIPTION -> string
-- Represents the description of the command
-- export
export TEXT_COMMAND_DESCRIPTION = "Cleans the project of gmodproj generated files"

-- ::configureCommand(Options options) -> void
-- Configures the input of the command
-- export
export configureCommand = (options) ->
    with options
        \boolean "clean-all", "Cleans all generated files"
        \boolean "clean-logs", "Cleans generated log files"
        \boolean "no-cache", "Disables cleaning of generated cache files"
        \boolean "no-logs", "Disables cleaning of generated log files"

-- ::executeCommand(Options options) -> void
-- Cleans the generated project files within the project
-- export
export executeCommand = (options) ->
    if isdirSync(PROJECT_PATH.cache) and not options\get("no-cache")
        cleanDirectory(PROJECT_PATH.cache)

    if isdirSync(PROJECT_PATH.logs)
        if not options\get("no-cache") and (options\get("clean-all") or options\get("clean-logs"))
            cleanDirectory(PROJECT_PATH.logs)

    logInfo("Finished cleaning project files")