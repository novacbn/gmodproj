
--
-- lua-LIVR : <http://fperrad.github.com/lua-LIVR/>
--

local pairs = pairs
local require = require
local type = type
local _ENV = nil

return {
    nested_object = function (rule_builders, livr)
        local new = require'LIVR/Validator'.new
        local validator = new(livr):register_rules(rule_builders):prepare()
        return function (nested_object)
            if nested_object == nil or nested_object == '' then
                return nested_object
            end
            if type(nested_object) ~= 'table' then
                return nested_object, 'FORMAT_ERROR'
            end
            return validator:validate(nested_object)
        end
    end,

    list_of = function (rule_builders, ...)
        local rules = { ... }
        if #rules == 1 then
            rules = rules[1]
        end
        local new = require'LIVR/Validator'.new
        local validator = new{ field = rules }:register_rules(rule_builders):prepare()
        return function (values)
            if values == nil or values == '' then
                return values
            end
            if type(values) ~= 'table' then
                return values, 'FORMAT_ERROR'
            end
            local results = {}
            local errors = {}
            local has_error
            for i = 1, #values do
                local val = values[i]
                local result, err = validator:validate{ field = val }
                result = result and result.field
                err = err and err.field
                results[i] = result
                errors[i] = err
                has_error = has_error or err
            end
            if has_error then
                results = nil
            else
                errors = nil
            end
            return results, errors
        end
    end,

    list_of_objects = function (rule_builders, livr)
        local new = require'LIVR/Validator'.new
        local validator = new(livr):register_rules(rule_builders):prepare()
        return function (objects)
            if objects == nil or objects == '' then
                return objects
            end
            if type(objects) ~= 'table' then
                return objects, 'FORMAT_ERROR'
            end
            local results = {}
            local errors = {}
            local has_error
            for i = 1, #objects do
                local obj = objects[i]
                local result, err = validator:validate(obj)
                results[i] = result
                errors[i] = err
                has_error = has_error or err
            end
            if has_error then
                results = nil
            else
                errors = nil
            end
            return results, errors
        end
    end,

    list_of_different_objects = function (rule_builders, selector_field, livrs)
        local new = require'LIVR/Validator'.new
        local validators = {}
        for selector_value, livr in pairs(livrs) do
            local validator = new(livr):register_rules(rule_builders):prepare()
            validators[selector_value] = validator
        end
        return function (objects)
            if objects == nil or objects == '' then
                return objects
            end
            if type(objects) ~= 'table' then
                return objects, 'FORMAT_ERROR'
            end
            local results = {}
            local errors = {}
            local has_error
            for i = 1, #objects do
                local obj = objects[i]
                if type(obj) ~= 'table' or not obj[selector_field] or not validators[obj[selector_field]] then
                    errors[i] = 'FORMAT_ERROR'
                    has_error = true
                else
                    local validator = validators[obj[selector_field]]
                    local result, err = validator:validate(obj)
                    results[i] = result
                    errors[i] = err
                    has_error = has_error or err
                end
            end
            if has_error then
                results = nil
            else
                errors = nil
            end
            return results, errors
        end
    end,

    variable_object = function (rule_builders, selector_field, livrs)
        local new = require'LIVR/Validator'.new
        local validators = {}
        for selector_value, livr in pairs(livrs) do
            local validator = new(livr):register_rules(rule_builders):prepare()
            validators[selector_value] = validator
        end
        return function (object)
            if object == nil or object == '' then
                return object
            end
            if type(object) ~= 'table' or not object[selector_field] or not validators[object[selector_field]] then
                return object, 'FORMAT_ERROR'
            end
            local validator = validators[object[selector_field]]
            return validator:validate(object)
        end
    end,

    ['or'] = function (rule_builders, ...)
        local rule_sets = { ... }
        local validators = {}
        local new = require'LIVR/Validator'.new
        for i = 1, #rule_sets do
            local validator = new{ field = rule_sets[i] }:register_rules(rule_builders):prepare()
            validators[#validators+1] = validator
        end
        return function (value)
            if value == nil or value == '' then
                return value
            end
            local result, last_error
            for i = 1, #validators do
                result, last_error = validators[i]:validate{ field = value }
                if result then
                    return result.field
                end
                last_error = last_error.field
            end
            return nil, last_error
        end
    end,
}

--
-- Copyright (c) 2018 Francois Perrad
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
