import next, type, unpack from _G
import rep from string
import concat, insert from table

import Options from "novacbn/command-ops/Options"

-- ::TEMPLATE_EXAMPLE_TEXT(string binary, string command, string example, number spaces?) -> string
-- Formats an example for the help text
--
TEMPLATE_EXAMPLE_TEXT = (binary, command, example, spaces=10) -> "#{rep(' ', spaces)}#{binary} #{command} #{example}"

-- ::TEMPLATE_HELP_TEXT(string usage, string examples, string description, string options) -> string
-- Formats the sub command's help text
--
TEMPLATE_HELP_TEXT = (usage, examples, description, options) -> "#{description}
Usage:    #{usage}#{examples and '\n\nExamples: '..examples or ''}#{options and '\n\nOptions:\n'..options or ''}"

-- ::TEMPLATE_USAGE_TEXT(string binary, string command, string syntax) -> string
-- Formats the usage syntax for the help text
--
TEMPLATE_USAGE_TEXT = (binary, command, syntax) -> "#{binary} #{command}#{syntax and ' '..syntax or ''}"

-- Command::Command()
-- Represents a registered sub command
-- export
export Command = (name, description, callback) -> {
    -- Command::callback -> function
    -- Represents the callback of the sub command
    --
    callback: callback

    -- Command::description -> string
    -- Represents the description of the sub command
    --
    description: description

    -- Command:examples -> table
    -- Represents the examples of the sub command
    --
    examples: nil

    -- Command::name -> string
    -- Represents the name of the sub command
    --
    name: name

    -- Command::options -> Options
    -- Represents the options configuration of the sub command
    --
    options: Options()

    -- Command::syntax -> string
    -- Represents the syntax of the sub command
    --
    syntax: nil

    -- Command::addExample(string example) -> void
    -- Adds an example text to the sub command's help text
    --
    addExample: (example) =>
        error("bad argument #1 to 'addExample' (expected string)") unless type(example) == "string"

        @examples = {} unless @examples
        insert(@examples, example)

    -- Command::exec(string binary, table flags, table arguments) -> void
    -- Executes the sub command
    --
    exec: (binary, flags, arguments) =>
        err = @options\parse(binary, flags)
        if err then print(err)
        else callback(@options, unpack(arguments))

    -- Command::formatHelp() -> string
    -- Formats the help text of the sub command
    --
    formatHelp: (binary) =>
        usage = TEMPLATE_USAGE_TEXT(binary, name, @syntax)

        local examples
        if @examples
            first       = TEMPLATE_EXAMPLE_TEXT(binary, name, @examples[1], 0)
            examples    = [TEMPLATE_EXAMPLE_TEXT(binary, name, example) for example in *@examples[2,]]
            insert(examples, 1, first)
            examples    = concat(examples, "\n")

        local options
        if next(@options.options)
            options = @options\formatHelp()

        return TEMPLATE_HELP_TEXT(usage, examples, @description, options)

    -- Command:setSyntax(string syntax) -> void
    -- Sets the syntax for the command's help text
    --
    setSyntax: (syntax) =>
        error("bad argument #1 to 'setSyntax' (expected string)") unless type(syntax) == "string"
        @syntax = syntax
}