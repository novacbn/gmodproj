import match from string

import readFileSync from require "fs"
import gsplit from require "glue"

import fromString from "gmodproj/lib/datafile"
import logError, logOptionsError from "gmodproj/lib/logging"
import validateOptions from "gmodproj/lib/utilities"

-- ConfigurationOptions::ConfigurationOptions()
-- Represents a configuration with validation
export class ConfigurationOptions
    -- ConfigurationOptions::configNamespace -> string
    -- Represents the namespace path of this configuration
    configNamespace: ""

    -- ConfigurationOptions::defaultConfiguration -> table
    -- Represents the default configuration values of the packager type
    defaultConfiguration: {}

    -- ConfigurationOptions::configurationRules -> table
    -- Represents a LIVR ruleset for validating the configuration
    configurationRules: {}

    -- ConfigurationOptions::fromString(string dataString) -> ConfigurationOptions
    -- Shortcut method for parsing a DataFile string
    fromString: (dataString) =>
        options = fromString(dataString)
        return self(options)

    -- ConfigurationOptions::readFile(string filePath) -> ConfigurationOptions
    -- Shortcut method for reading a DataFile file
    readFile: (filePath) =>
        -- Read the datafile into memory, then parse
        contents = readFileSync(filePath)
        return self\fromString(contents)

    -- ConfigurationOptions::new(table options?)
    -- Constructor for ConfigurationOptions
    new: (options={}, parentNamespace) =>
        -- Validate the specified options and fatally log if an error occured
        options, errors = validateOptions(options, @configurationRules, @defaultConfiguration)
        logOptionsError(@configNamespace, errors) if errors

        -- Cache the validated options
        @options = options

    -- ConfigurationOptions::get(string name) -> any
    -- Returns the configuration value of the name
    get: (name) =>
        -- Bypass the dot-path loop if no dots were found
        return @options[name] unless match(name, "%.")

        -- Make a namespace splitter iterator
        iterator = gsplit(name, "%.")

        -- Start with the base object and then follow the dot-path
        value   = @options
        value   = value[key] for key in iterator

        -- Return the remaining value
        return value