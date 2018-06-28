import ipairs from _G
import match, lower, rep from string
import concat, insert from table

-- ::PATTERN_FLAG_FULL -> string
-- Represents a Lua pattern to validate full-sized CLI flags
--
PATTERN_FLAG_FULL = "^%-%-[%w%-]+"

-- ::PATTERN_FLAG_MINI -> string
-- Represents a Lua pattern to validate mini-sized CLI flags
--
PATTERN_FLAG_MINI = "^%-[%w]+"

-- ::PATTERN_FLAG_VALUE -> string
-- Represents a Lua pattern to extract the value from the flag
--
PATTERN_FLAG_VALUE = "(.+)%s?=%s?(.+)"

-- ::TABLE_AFFIRMATIVE_VALUES -> table
-- Represents the list of possible affirmative strings
--
TABLE_AFFIRMATIVE_VALUES = {value, true for value in *{
    "1"
    "y"
    "yes"
    "t"
    "true"
    true
}}

-- ::isAffirmative(any value) -> boolean
-- Returns if the value is an affirmative value
-- export
export isAffirmative = (value) ->
    value = lower(value) if type(value) == "string"
    return TABLE_AFFIRMATIVE_VALUES[value] or false

-- ::layoutText(table lines, number spaces?) -> string
-- Lays out two-column text by a tab seperator
-- export
export layoutText = (lines, spaces=4) ->
    lines       = [line for line in *lines] 
    maxLength   = 0

    for index, line in ipairs(lines)
        first, second   = match(line, "^(.+)\t(.+)$")
        maxLength       = #first if #first > maxLength

    for index, line in ipairs(lines)
        first, second   = match(line, "^(.+)\t(.+)$")
        lines[index]    = first..rep(" ", (maxLength + spaces) - #first)..second

    concat(lines, "\n")

-- ::parseArguments(table argv) -> table, table
-- Parses a table of arguments, splitting flags and commands
-- export
export parseArguments = (argv) ->
    arguments, flags    = {}, {}
    firstArgument       = false

    for argument in *argv
        -- If we already reached the first argument, skip parsing flag parsing
        if not firstArgument and (match(argument, PATTERN_FLAG_MINI) or match(argument, PATTERN_FLAG_FULL))
            flag, value = match(argument, PATTERN_FLAG_VALUE)
            if flag and value then flags[flag] = value
            else flags[argument] = true

            continue

        firstArgument = true
        insert(arguments, argument)

    return arguments, flags