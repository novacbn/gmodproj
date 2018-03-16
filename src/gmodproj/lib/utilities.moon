import pcall, type from _G
import upper from string

livr = require "LIVR/Validator"
import merge from require "glue"

-- ::LIVR_UTILITY_RULES -> table
-- Represents extra utility rules to use in LIVR validation rules
LIVR_UTILITY_RULES =
    is: (check) =>
        -- Preformat the error id
        err = "NOT_#{upper(check)}"

        -- Return a wrapper rule checker
        return (value) ->
            -- If the type does not match, fail the check, otherwise return unmodified
            return nil, err if type(value) ~= check
            return value

livr.register_default_rules(LIVR_UTILITY_RULES)

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

