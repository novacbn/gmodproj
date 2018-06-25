import unlinkSync from require "fs"
import join from require "path"
import isdirSync, isfileSync, walkSync from "novacbn/luvit-extras/fs"

import PROJECT_PATH from "novacbn/gmodproj/lib/constants"
import logInfo from "novacbn/gmodproj/lib/logging"
import collectFiles from "novacbn/gmodproj/lib/utilities/fs"

-- ::cleanDirectory(string directory) -> void
-- Removes all files within the specified directory
--
cleanDirectory = (directory) ->
    for file in *walkSync(directory)
        unlinkSync(file) if isfileSync(file)

-- ::formatDescription(table flags) -> string
-- Formats the help description of the command
-- export
export formatDescription = (flags) ->
    return "clean\t\t\t\t\tCleans the build cache of the project"

-- ::executeCommand(table flags) -> void
-- Cleans the generated project files within the project
-- export
export executeCommand = (flags) ->
    if isdirSync(PROJECT_PATH.cache) and not (flags["-nc"] or flags["--no-cache"])
        cleanDirectory(PROJECT_PATH.cache)

    if isdirSync(PROJECT_PATH.logs)
        if not (flags["-nl"] or flags["--no-logs"]) and (flags["-ca"] or flags["-cl"] or flags["--clean-all"] or flags["--clean-logs"])
            cleanDirectory(PROJECT_PATH.logs)

    logInfo("Finished cleaning project files")