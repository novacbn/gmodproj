import ipairs, pairs, pcall, type from _G
import upper from string

livr = require "LIVR/Validator"
import merge from require "glue"

-- ::LIVR_UTILITY_RULES -> table
-- Represents extra utility rules to use in LIVR validation rules
LIVR_UTILITY_RULES =
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

livr.register_default_rules(LIVR_UTILITY_RULES)

-- getIndex(table sourceTable, any searchValue) -> number or nil
-- Returns the first instance index of the searched value
export getIndex = (sourceTable, searchValue) ->
    -- Loop through the table, filtering for the searched value
    for index, value in ipairs(sourceTable)
        return index if value == searchValue

    -- Return nil if no index was found
    return nil

-- ::isSequentialTable(table sourceTable) -> boolean
-- Returns if the table is a numeric non-sparse table(i.e. an array)
export isSequentialTable = (sourceTable) ->
    countedLength, previousIndex = 0, nil
    for index, value in ipairs(sourceTable)
        -- If there was a previously searched index, check if the table is sparse
        if previousIndex
            return false if (previousIndex - index) > 1

        -- Store the previous index and increment the amount of keypairs counted
        previousIndex   = index
        countedLength   += 1

    -- Return true if the amount of keypairs counted matches the table's length
    return countedLength == #sourceTable

-- ::isNumericTable(table sourceTable) -> boolean
-- Returns if the keys of the table are all numeric
export isNumericTable = (sourceTable) ->
    for key, value in pairs(sourceTable)
        return false unless type(key) == "number"

    return true

-- ::tryImport(string importName, any exportKey?) -> boolean, any | string
-- Trys to import the given import name, if an export key is provided, it'll return that export instead of full table
export tryImport = (importName, exportKey) ->
    -- If specified export key, return the specific export, otherwise entire exports table
    return pcall(() -> dependency(importName)) if exportKey == nil
    return pcall(() -> dependency(importName)[exportKey])

-- ::validateOptions(table options, table validationRules, table defaultOptions?) -> table?, table?
-- Validates the provided options with the rules, merging any default options provided aswell
export validateOptions = (options, validationRules, defaultOptions) ->
    -- Merge any provided default options
    options = merge(options, defaultOptions) if defaultOptions

    -- Make a new validator and return the validation results
    validator = livr.new(validationRules)
    return validator\validate(options)

