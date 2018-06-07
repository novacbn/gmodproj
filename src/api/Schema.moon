import pairs from _G
import gsub, upper from string
import concat, insert from table

livr = require "LIVR/Validator"

import deepMerge from "novacbn/novautils/table"
import Object from "novacbn/novautils/utilities/Object"

-- ::LIVR_ERROR_LOOKUP -> table
-- Represents a human-readable lookup for LIVR errors
--
LIVR_ERROR_LOOKUP = {
    NOT_ARRAY:      "expected array of values"
    NOT_STRING:     "expected string value"
    NOT_BOOLEAN:    "expected boolean value"
    MINIMUM_ITEMS:  "expected a number of minimum array items"
    WRONG_FORMAT:   "option did not match pattern"
}

-- ::LIVR_UTILITY_RULES -> table
-- Represents extra utility rules to use in LIVR validation rules
--
LIVR_UTILITY_RULES = {
    is_key_pairs: (keyCheck, valueCheck) =>
        keyValidator    = @is(keyCheck)
        valueValidator  = @is(valueCheck)

        return (tbl) ->
            local err
            for key, value in pairs(tbl)
                _, err = keyValidator(key)
                return nil, err if err

                _, err = valueValidator(value)
                return nil, err if err

            return tbl

    is: (check) =>
        if type(check) == "table"
            -- Format the error string for log matching
            err = "NOT_#{upper(check[1])}"

            -- Return a wrapper rule checker
            return (value) ->
                -- Validate that the value's type is in the listed rules
                valueType = type(value)
                for ruleType in *check
                    return value if valueType == ruleType

                -- Failed to validate return the error string
                return nil, err
        else
            -- Format the error string for log matching
            err = "NOT_#{upper(check)}"

            -- Return a wrapper rule checker
            return (value) ->
                -- Validate that the value's type matches the rule
                return value if type(value) == check

                -- Failed to validate, return the error string
                return nil, err


    min_items: (amount) =>
        return (value) ->
            -- Validate the table before returning
            return nil, "NOT_ARRAY" unless type(value) == "table"
            return nil, "MINIMUM_ITEMS" unless #value >= amount

            return value
}

livr.register_default_rules(LIVR_UTILITY_RULES)

-- ::PATTERN_PATH_EXTRACT -> string
-- Represents a pattern to extract elements of dot pathes, e.g. "x.y.z"
--
PATTERN_PATH_EXTRACT = "[^%.]+"

-- ::formatOptionsError(string namespace, table errors, table stringBuffer?) -> string
-- Formats LIVR errors into a multi-line string
--
formatOptionsError = (namespace, errors, stringBuffer) ->
    -- If this is the originating function call, make a new string buffer
    originatingCall = not stringBuffer and true or false
    stringBuffer    = {} if originatingCall

    -- Recursively build the options error string
    for optionName, errorID in pairs(errors)
        switch type(errorID)
            -- Format into option error, use the error id if no human-readable message exists
            when "string" then insert(stringBuffer, "bad option '#{optionName}' to '#{namespace}' (#{LIVR_ERROR_LOOKUP[errorID] or errorID})")
            else
                -- If there is an existing namespace, use and format it with the option name
                if namespace and #namespace > 0 then formatOptionsError("#{namespace}.#{optionName}", errorID, stringBuffer)
                else formatOptionsError(optionName, errorID, stringBuffer)

    -- Return the concated buffer if originating function call
    return concat(stringBuffer, "\n") if originatingCall

-- Schema::Schema()
-- Represents a generic LIVR Schema
-- export
export Schema = Object\extend {
    -- Schema::default -> table
    -- Represents the default values that are merged before validation
    --
    default: nil

    -- Schema::namespace -> string
    -- Represents the nested namespace of the schema
    --
    namespace: nil

    -- Schema::options -> table
    -- Represents the validated options of the Schema
    --
    options: nil

    -- Schema::schema -> table
    -- Represents the LIVR validation schema
    --
    schema: nil

    -- Schema::constructor()
    -- Constructor for Schema
    --
    constructor: (options={}) =>
        -- Merge default values with provided options before validation
        deepMerge(options, @default) if @default

        -- Validate the options with the LIVR schema
        validator       = livr.new(@schema)
        options, errors = validator\validate(options)
        error(formatOptionsError(@namespace, errors)) if errors

        @options = options

    -- Schema::get(string dotPath) -> any
    -- Returns the value found at the key's dot path, e.g. "x.y.z"
    --
    get: (dotPath) =>
        -- Start with the validated options
        value = @options

        -- Extract each element of the dot path and index the previous value
        gsub(dotPath, PATTERN_PATH_EXTRACT, (pathElement) ->
            error("bad argument #1 to 'get' (key '#{pathElement}' of '#{dotPath}' is not a table)") unless type(value) == "table"
            value = value[pathElement]
        )

        return value
}