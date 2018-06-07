import print from _G

import APPLICATION_CORE_VERSION from "novacbn/gmodproj/lib/constants"

-- ::TEXT_COMMAND_VERSION -> string
-- Represents the current version of the application
-- export
export TEXT_COMMAND_VERSION = "#{APPLICATION_CORE_VERSION[1]}.#{APPLICATION_CORE_VERSION[2]}.#{APPLICATION_CORE_VERSION[3]} Pre-alpha"

-- ::formatDescription(table flags) -> string
-- Formats the help description of the command
-- export
export formatDescription = (flags) ->
    return "version\t\t\t\t\tDisplays the version text of application"

-- ::executeCommand(table flags) -> void
-- Prints the version of the application to console
-- export
export executeCommand = (flags) ->
    print(TEXT_COMMAND_VERSION)