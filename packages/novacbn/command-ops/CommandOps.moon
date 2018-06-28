import pairs, print, type from _G
import match from string
import sort, remove from table

import Command from "novacbn/command-ops/Command"
import layoutText, parseArguments from "novacbn/command-ops/utilities"

-- ::PATTERN_BINARY_NAME -> string
-- Represents a Lua pattern to validate the command's binary
--
PATTERN_BINARY_NAME = "^[%w%-%.%_]+$"

-- ::TEMPLATE_HELP_TEXT(string name, string version?, string binary, string commands) -> string
-- Formats the help text for the main command
--
TEMPLATE_HELP_TEXT = (name, version, binary, commands) -> "#{name}#{version and ' :: '..version or ''}
Usage:    #{binary} [flags] [command]

Commands:
#{commands}"

-- CommandOps::CommandOps()
-- Represents the main CLI configurator
-- export
export CommandOps = (cliName, binary, version) ->
    error("bad argument #1 to 'CommandOps' (expected string)") unless type(cliName) == "string"
    error("bad argument #2 to 'CommandOps' (expected string)") unless type(binary) == "string"
    error("bad argument #2 to 'CommandOps' (malformed binary)") unless match(binary, PATTERN_BINARY_NAME)
    error("bad argument #3 to 'CommandOps' (expected string)") unless version == nil or type(version) == "string"

    return {
        -- CommandOps::binary -> string
        -- Represents the name of the command's binary
        --
        binary: binary

        -- CommandOps::commands -> table
        -- Represents the configured sub commands of the command
        --
        commands: {}

        -- CommandOps::name -> string
        -- Represents the full-text name of the command
        --
        name: name

        -- CommandOps::version -> string
        -- Represents the version of the command
        --
        version: version

        -- CommandOps::command(string name, string description, function callback) -> void
        -- Registers a new sub command
        --
        command: (name, description, callback) =>
            error("bad argument #1 to 'command' (expected string)") unless type(name) == "string"
            error("bad argument #1 to 'command' (existing command)") if @commands[name]
            error("bad argument #2 to 'command' (expected string)") unless type(description) == "string"
            error("bad argument #3 to 'command' (expected function)") unless type(callback) == "function"

            command             = Command(name, description, callback)
            @commands[name]     = command
            return command

        -- CommandOps::exec(table arguments) -> void
        -- Routes and executes to the appropriate sub command
        --
        exec: (arguments) =>
            arguments, flags    = parseArguments(arguments)
            name                = remove(arguments, 1)

            if name == nil or name == "help" then @printHelp(arguments[1])
            elseif @commands[name]
                command = @commands[name]
                command\exec(binary, flags, arguments)
            else print("unknown command '#{name}'")

        -- CommandOps::formatHelp() -> string
        -- Formats the help text of the command
        --
        formatHelp: () =>
            commands    = [name for name, command in pairs(@commands)]
            sort(commands)
            commands    = ["    "..name.."\t"..@commands[name].description for name in *commands]
            commands    = layoutText(commands, 4)

            return TEMPLATE_HELP_TEXT(cliName, version, binary, commands)

        -- CommandOps::printHelp(string name?) -> void
        -- Prints the help text for the relevant sub command
        --
        printHelp: (name) =>
            unless name
                print(@formatHelp())
                return

            command = @commands[name]
            unless command
                if name then print("unknown command '#{name}'")
                else print("missing command")
            else print(command\formatHelp(binary))
    }