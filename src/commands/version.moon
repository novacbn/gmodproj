import print from _G

import APPLICATION_CORE_VERSION from "novacbn/gmodproj/lib/constants"

-- ::TEXT_COMMAND_VERSION -> string
-- Represents the current version of the application
-- export
export TEXT_COMMAND_VERSION = "#{APPLICATION_CORE_VERSION[1]}.#{APPLICATION_CORE_VERSION[2]}.#{APPLICATION_CORE_VERSION[3]} Pre-alpha"

-- ::TEXT_COMMAND_DESCRIPTION -> string
-- Represents the description of the command
-- export
export TEXT_COMMAND_DESCRIPTION = "Displays the current version of gmodproj"

-- ::executeCommand(Options options) -> void
-- Prints the version of the application to console
-- export
export executeCommand = (options) ->
    print(TEXT_COMMAND_VERSION)