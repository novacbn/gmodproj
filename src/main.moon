import pairs, print, unpack from _G
import lower, match from string
import concat, insert, remove, sort from table

import TEXT_COMMAND_VERSION from "novacbn/gmodproj/commands/version"
import formatCommand from "novacbn/gmodproj/lib/utilities/fs"
import logFatal, logInfo, toggleConsoleLogging, toggleFileLogging from "novacbn/gmodproj/lib/logging"

-- ::APPLICATION_SUB_COMMANDS -> table
-- Represents the accepted subcommands of gmodproj
--
APPLICATION_SUB_COMMANDS = {
    bin:        dependency "novacbn/gmodproj/commands/bin"
    build:      dependency "novacbn/gmodproj/commands/build"
    new:        dependency "novacbn/gmodproj/commands/new"
    version:    dependency "novacbn/gmodproj/commands/version"
    watch:      dependency "novacbn/gmodproj/commands/watch"
}

-- ::APPLICATION_COMMAND_FLAGS -> table
-- Represents help text of the usable command line flags
--
APPLICATION_COMMAND_FLAGS = {
    {"-q",  "--quiet",          "Disables logging to console"}
    {"-nc", "--no-cache",       "Disables caching of built project files"}
    {"-nf", "--no-file",        "Disables logging to files"}
    {"-ws", "--watch-search",   "Watches package search paths specified in project manifest"}
}

-- ::PATTERN_FLAG_MINI -> string
-- Represents a Lua pattern to determine if the string is a mini command flag
--
PATTERN_FLAG_MINI = "%-[%w%-]+"

-- ::PATTERN_FLAG_FULL -> string
-- Represents a Lua pattern to determine if the string is a full command flag
--
PATTERN_FLAG_FULL = "%-%-[%w%-]+"

-- ::TEMPLATE_TEXT_HELP(string version, string commands, string flags) -> string
-- Formats the help text of the application
--
TEMPLATE_TEXT_HELP = (version, commands, flags) -> "Garry's Mod Project Manager :: #{version}
Syntax:		gmodproj [flags] [command]

Examples:	gmodproj bin prebuild
		gmodproj build production
		gmodproj new addon novacbn my-addon

Flags:
#{flags}

Commands:
#{commands}"

-- ::displayHelpText(table flags) -> void
-- Displays the help text of gmodproj
--
displayHelpText = (flags) ->
    -- Format and sort the application sub commands
    commandsText = [command for command, applicationCommand in pairs(APPLICATION_SUB_COMMANDS)]
    sort(commandsText)
    commandsText    = ["\t"..APPLICATION_SUB_COMMANDS[command].formatDescription(flags) for command in *commandsText]
    commandsText    = concat(commandsText, "\n")
    
    -- Format the application command flags
    flagsText   = ["\t#{flag[1]}, #{flag[2]}\t\t\t\t#{flag[3]}" for flag in *APPLICATION_COMMAND_FLAGS]
    flagsText   = concat(flagsText, "\n")

    print(TEMPLATE_TEXT_HELP(TEXT_COMMAND_VERSION, commandsText, flagsText))

-- ::parseArguments(table argv) -> table, table
-- Parses a provided table of commands line arguments, splitting flags and arguments into two tables
--
parseArguments = (argv) ->
    arguments, flags = {}, {}

    for argument in *argv
        if match(argument, PATTERN_FLAG_MINI) or match(argument, PATTERN_FLAG_FULL)
            flags[lower(argument)] = true

        else insert(arguments, argument)

    return arguments, flags

-- Parse the command line arguments and sub command
arguments, flags    = parseArguments(process.argv)
subCommand          = remove(arguments, 1)

-- Disable loggers that were flagged
toggleConsoleLogging(not (flags["-q"] or flags["--quiet"]))
toggleFileLogging(not (flags["-nf"] or flags["--no-file"]))

-- Log to file the arguments used to start the application
logInfo("Application starting with: #{formatCommand('gmodproj', ...)}", {
    console:    false
    file:       true
})

if subCommand == "help" then displayHelpText(flags)
else
    applicationCommand = APPLICATION_SUB_COMMANDS[subCommand]
    if applicationCommand then applicationCommand.executeCommand(flags, unpack(arguments))
    else logFatal("Sub command '#{subCommand}' is invalid!")