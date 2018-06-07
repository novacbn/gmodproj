import tostring from _G
import byte, gmatch, gsub, lower from string
import concat from table

import makeLookupMap from "novacbn/novautils/table"

-- ::PATTERN_TEMPLATE_TOKEN -> string
-- Represents an extraction pattern for tokens in templates
PATTERN_TEMPLATE_TOKEN = "(%${)(%w+)(})"

-- ::MAP_AFFIRMATIVE_VALUES -> table
-- Represents a map of possible affirmative user values
MAP_AFFIRMATIVE_VALUES = makeLookupMap {
    "y",
    "yes",
    "t",
    "true",
    "1"
}

-- ::isAffirmative(string userValue) -> boolean
-- Returns if the user value is an affirmative response
export isAffirmative = (userValue) ->
    return MAP_AFFIRMATIVE_VALUES[lower(userValue)] or false

-- ::makeTemplate(string stringTemplate) -> function
-- Makes a simple string substitution template function
export makeTemplate = (stringTemplate) ->
    return (templateTokens) ->
        -- Substitute tokens in the template
        return gsub(stringTemplate, PATTERN_TEMPLATE_TOKEN, (startBoundry, tokenName, endBoundry) ->
            -- If the token does not exist, return as extracted
            tokenValue = templateTokens[tokenName]
            unless tokenValue then return startBoundry..tokenName..endBoundry
            return tostring(tokenValue)
        )

-- ::makeStringEscape(table lookup) -> function
-- Makes a string naive replacement function via a token, replacement array
export makeStringEscape = (lookup) ->
    -- Make a helper escape function
    return (value) ->
        -- Escape every pair of strings and return modified string
        value = gsub(value, tokens[1], tokens[2]) for tokens in *lookup
        return value

-- ::toBytes(string sourceString) -> table
-- Converts a string into a table of bytes
export toBytes = (sourceString) ->
    return [byte(subString) for subString in gmatch(sourceString, ".")]

-- ::toByteString(string sourceString) -> table
-- Converts a string into a table of bytes that can be parsed by Lua
export toByteString = (sourceString) ->
    byteTable = toBytes(sourceString)
    return "{"..concat(byteTable, ",").."}"