import pairs from _G

import CommandOps from "novacbn/command-ops/CommandOps"

import TEXT_COMMAND_VERSION from "novacbn/gmodproj/commands/version"
import formatCommand from "novacbn/gmodproj/lib/utilities/fs"
import logInfo, toggleConsoleLogging, toggleFileLogging from "novacbn/gmodproj/lib/logging"

-- ::APPLICATION_SUB_COMMANDS -> table
-- Represents the accepted sub commands of gmodproj
--
APPLICATION_SUB_COMMANDS = {
    add:        dependency "novacbn/gmodproj/commands/add"
    bin:        dependency "novacbn/gmodproj/commands/bin"
    build:      dependency "novacbn/gmodproj/commands/build"
    clean:      dependency "novacbn/gmodproj/commands/clean"
    init:       dependency "novacbn/gmodproj/commands/init"
    new:        dependency "novacbn/gmodproj/commands/new"
    version:    dependency "novacbn/gmodproj/commands/version"
    watch:      dependency "novacbn/gmodproj/commands/watch"
}

-- Disable loggers that were flagged
--toggleConsoleLogging(not (flags["-q"] or flags["--quiet"]))
--toggleFileLogging(not (flags["-nf"] or flags["--no-file"]))

-- Log to file the arguments used to start the application
logInfo("Application starting with: #{formatCommand('gmodproj', ...)}", {
    console:    false
    file:       true
})

commandOps = CommandOps("Garry's Mod Project Manager", "gmodproj", TEXT_COMMAND_VERSION)

for name, exports in pairs(APPLICATION_SUB_COMMANDS)
    command = commandOps\command(name, exports.TEXT_COMMAND_DESCRIPTION, exports.executeCommand)

    command\setSyntax(exports.TEXT_COMMAND_SYNTAX) if exports.TEXT_COMMAND_SYNTAX
    if exports.TEXT_COMMAND_EXAMPLES
        command\addExample(example) for example in *exports.TEXT_COMMAND_EXAMPLES

    exports.configureCommand(command.options) if exports.configureCommand

commandOps\exec(process.argv)