
--
-- lua-LIVR : <http://fperrad.github.com/lua-LIVR/>
--

local assert = assert
local next = next
local pairs = pairs
local pcall = pcall
local require = require
local setmetatable = setmetatable
local tostring = tostring
local type = type
local unpack = table.unpack or unpack
local _ENV = nil
local m = {}
local mt = {}

local common    = require 'LIVR/Rules/Common'
local string    = require 'LIVR/Rules/String'
local numeric   = require 'LIVR/Rules/Numeric'
local special   = require 'LIVR/Rules/Special'
local meta      = require 'LIVR/Rules/Meta'
local modifiers = require 'LIVR/Rules/Modifiers'
local has_pcre  = pcall(require, 'rex_pcre')

m.default_rules = {
    required                    = common.required,
    not_empty                   = common.not_empty,
    not_empty_list              = common.not_empty_list,
    any_object                  = common.any_object,
    one_of                      = string.one_of,
    min_length                  = string.min_length,
    max_length                  = string.max_length,
    length_equal                = string.length_equal,
    length_between              = string.length_between,
    like                        = has_pcre and string.like or string.like_lua,
    like_lua                    = string.like_lua,
    string                      = string.string,
    eq                          = string.equal,
    integer                     = numeric.integer,
    positive_integer            = numeric.positive_integer,
    decimal                     = numeric.decimal,
    positive_decimal            = numeric.positive_decimal,
    max_number                  = numeric.max_number,
    min_number                  = numeric.min_number,
    number_between              = numeric.number_between,
    email                       = special.email,
    equal_to_field              = special.equal_to_field,
    url                         = special.url,
    iso_date                    = special.iso_date,
    nested_object               = meta.nested_object,
    variable_object             = meta.variable_object,
    list_of                     = meta.list_of,
    list_of_objects             = meta.list_of_objects,
    ['or']                      = meta['or'],
    list_of_different_objects   = meta.list_of_different_objects,
    trim                        = modifiers.trim,
    to_lc                       = modifiers.to_lc,
    to_uc                       = modifiers.to_uc,
    remove                      = modifiers.remove,
    leave_only                  = modifiers.leave_only,
    default                     = modifiers.default,
}

m.default_auto_trim = false

function m.new (livr_rules, is_auto_trim)
    local obj = {
        livr_rules         = livr_rules,
        validators         = nil,
        validator_builders = {},
        errors             = nil,
        is_auto_trim       = is_auto_trim or m.default_auto_trim,
    }
    setmetatable(obj, { __index = mt })
    obj:register_rules(m.default_rules)
    return obj
end

function m.register_default_rules (rules)
    for rule_name, rule_builder in pairs(rules) do
        assert(type(rule_name) == 'string')
        assert(type(rule_builder) == 'function', "RULE_BUILDER [" .. rule_name .. "] SHOULD BE A FUNCTION")
        m.default_rules[rule_name] = rule_builder
    end
end

local function _build_aliased_rule (alias)
    assert(alias.name, "Alias name required")
    assert(alias.rules, "Alias rules required")
    local livr = { value = alias.rules }
    return function (rule_builders)
        local validator = m.new(livr):register_rules(rule_builders):prepare()
        return function (value)
            local result, err = validator:validate{ value = value }
            result = result and result.value
            err = err and (alias.error or err.value)
            return result, err
        end
    end
end

function m.register_aliased_default_rule (alias)
    m.default_rules[alias.name] = _build_aliased_rule(alias)
end

function mt:prepare ()
    self.validators = {}
    for field, field_rules in pairs(self.livr_rules) do
        local validators = {}
        if type(field_rules) ~= 'table' then
            validators[#validators+1] = self:_build_validator(field_rules, {})
        else
            for k, v in pairs(field_rules) do
                local name, args
                if type(k) == 'number' then
                    if type(v) == 'table' then
                        name, args = next(v)
                    else
                        name = v
                        args = {}
                    end
                else
                    name = k
                    args = v
                end
                if type(args) ~= 'table' or (#args == 0 and next(args)) then
                    args = { args }
                end
                validators[#validators+1] = self:_build_validator(name, args)
            end
        end
        self.validators[field] = validators
    end
    return self
end

local function _auto_trim (data)
    if type(data) == 'string' then
        data = data:gsub('^%s+', '')
        data = data:gsub('%s+$', '')
    elseif type(data) == 'table' then
        for k, v in pairs(data) do
            data[k] = _auto_trim(v)
        end
    else
        data = tostring(data)
    end
    return data
end

function mt:validate (data)
    if not self.validators then
        self:prepare()
    end
    if type(data) ~= 'table' then
        return nil, 'FORMAT_ERROR'
    end
    if self.is_auto_trim then
        _auto_trim(data)
    end
    local errors = {}
    local result = {}
    local is_ok = true
    for field_name, validators in pairs(self.validators) do
        local value = data[field_name]
        for i = 1, #validators do
            local validator = validators[i]
            local field_result, err_code = validator(result[field_name] or value, data)
            if err_code then
                errors[field_name] = err_code
                is_ok = false
                break
            else
                result[field_name] = field_result
            end
        end
    end
    if is_ok then
        return result
    else
        return nil, errors
    end
end

function mt:register_rules (rules)
    for rule_name, rule_builder in pairs(rules) do
        assert(type(rule_name) == 'string')
        assert(type(rule_builder) == 'function', "RULE_BUILDER [" .. rule_name .. "] SHOULD BE A FUNCTION")
        self.validator_builders[rule_name] = rule_builder
    end
    return self
end

function mt:register_aliased_rule (alias)
    self.validator_builders[alias.name] = _build_aliased_rule(alias)
    return self
end

function mt:get_rules ()
    return self.validator_builders
end

function mt:_build_validator (name, args)
    assert(self.validator_builders[name], "Rule [" .. name .."] not registered")
    return self.validator_builders[name](self.validator_builders, unpack(args))
end

m._NAME = ...
m._VERSION = "0.0.1"
m._DESCRIPTION = "lua-LIVR : Lightweight validator supporting LIVR 2.0"
m._COPYRIGHT = "Copyright (c) 2018 Francois Perrad"
return m
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
