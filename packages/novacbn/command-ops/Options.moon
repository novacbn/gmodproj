import type from _G
import getenv from os
import gsub, match, sub, upper from string
import concat, insert, sort from table

import isAffirmative, layoutText from "novacbn/command-ops/utilities"

-- ::PATTERN_OPTION -> string
-- Represents a Lua pattern for validating a CLI option
--
PATTERN_OPTION = "^%l[%l%-]+$"

-- ::PATTERN_OPTIONS_PART -> string
-- Represents a Lua pattern for extracting secondary parts from a CLI option
--
PATTERN_OPTIONS_PART = "%-(%l)"

-- ::PATTERN_OPTION_TEXT(string flagMini, string flagFull, string description) -> string
-- Formats the help CLI flag text of the option
--
TEMPLATE_OPTION_TEXT = (flagMini, flagFull, description) -> "    #{flagMini}, #{flagFull}\t#{description}"

-- ::formatEnvFull(string binary, string option) -> string
-- Formats the application-specific environment option
--
formatEnvFull = (binary, option) ->
    command = gsub(binary, "%-", "_")
    option  = gsub(option, "%-", "_")

    return upper("#{binary}_#{option}")

-- ::formatFlagMini(string name) -> string
-- Formats the option into a mini CLI flag
--
formatFlagMini = (name) ->
    parts = {sub(name, 1, 1)}
    gsub(name, PATTERN_OPTIONS_PART, => insert(parts, @))

    return "-#{concat(parts)}"

-- ::makeOptionType(string typeName, function transform?) -> function
--
--
makeOptionType = (typeName, defaultValue, transform) ->
    return (self, name, description, default=defaultValue, validate) ->
        error("bad argument #1 to '#{typeName}' (expected string)") unless type(name) == "string"
        error("bad argument #2 to '#{typeName}' (expected string)") unless type(description) == "string"
        error("bad argument #3 to '#{typeName}' (expected #{typeName})") unless type(default) == typeName
        error("bad argument #4 to '#{typeName}' (expected function)") unless validate == nil or type(validate) == "function"

        error("bad argument #1 to '#{typeName}' (malformed option)") unless match(name, PATTERN_OPTION)
        error("bad argument #1 to '#{typeName}' (existing option)") if @options[name]

        flagMini = formatFlagMini(name)
        for name, option in pairs(@options)
            error("bad argument #1 to '#{typeName}' (duplicate mini CLI flag)") if option.flagMini == flagMini

        @options[name] = {
            description:    description
            default:        default
            validate:       validate
            transform:      transform

            flagMini:       flagMini
            flagFull:       "--#{name}"
            value:          nil
        }

-- Options::Options()
-- Represents a command-specific options configuration
-- export
export Options = () -> {
    -- Options::options -> table
    -- Represents the configured options
    --
    options: {}

    -- Options::formatHelp() -> string
    -- Formats the sub command's options for the help text
    --
    formatHelp: () =>
        options = [name for name, option in pairs(@options)]
        sort(options)
        for index, name in ipairs(options)
            option          = @options[name]
            options[index]  = TEMPLATE_OPTION_TEXT(option.flagMini, option.flagFull, option.description)

        return layoutText(options)

    -- Options::get(string name) -> any value
    -- Returns the end-user provided option value
    --
    get: (name) =>
        error("bad argument #1 to 'get' (expected string)") unless type(name) == "string"
        option = @options[name]
        error("bad argument #1 to 'get' (unexpected option)") unless @options[name]

        return option.value ~= nil and option.value or option.default

    -- Options::parse(string binary, table flags) -> string?
    -- Parses the CLI flags and environment variables for the configured options
    --
    parse: (binary, flags) =>
        for name, option in pairs(@options)
            value   = flags[option.flagMini]
            value   = flags[option.flagFull] if value == nil
            value   = getenv(formatEnvFull(binary, name)) if value == nil

            if option.transform
                value = option.transform(value)
                return "bad option to '#{flag.name}' (malformed value)" if value == nil

            if option.validate
                err = option.validate(value)
                return "bad option to '#{flag.name}' (#{err})" unless err

            option.value = value

    -- Options::boolean(string name, string description, boolean default?, function validate?) -> void
    --
    --
    boolean: makeOptionType("boolean", false, isAffirmative)

    -- Options::number(string name, string description, number default?, function validate?) -> void
    --
    --
    number: makeOptionType("number", 0, tonumber)

    -- Options::string(string name, string description, string default?, function validate?) -> void
    --
    --
    string: makeOptionType("string", "")
}