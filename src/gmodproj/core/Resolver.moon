import join from require "path"

import ConfigurationOptions from "gmodproj/api/ConfigurationOptions"
import PATH_DIRECTORY_PROJECT from "gmodproj/lib/constants"
import isFile from "gmodproj/lib/fsx"

-- ResolverOptions::ResolverOptions()
-- Represents the configuration options of the resolver
class ResolverOptions extends ConfigurationOptions
    -- ResolverOptions::configNamespace -> string
    -- Represents the namespace path of this configuration
    configNamespace: "Project.Resolver"

    -- ResolverOptions::defaultConfiguration -> table
    -- Represents the default configuration values of the packager type
    defaultConfiguration: {
        searchPaths: {
            join(PATH_DIRECTORY_PROJECT, "packages")
        }
    }

    -- ResolverOptions::configurationRules -> table
    -- Represents a LIVR ruleset for validating the configuration
    configurationRules: {
        searchPaths:        {list_of: {is: "string"}}
    }

-- Resolver::Resolver()
-- Represents the asset cache resolver
export class Resolver
    -- Resolver::sourceDirectory -> string
    -- Represents the package's directory of source code

    -- Resolver::new(string sourceDirectory, table options)
    -- Constructor for the package resolver
    new: (sourceDirectory, options) =>
        -- Validate the provided Resolver options
        @options = ResolverOptions(options)

        -- Cache the project's source directory
        @sourceDirectory = sourceDirectory

    -- Resolver::resolveAsset(string assetName, table assetTypes) -> Asset or nil, string or nil
    -- Resolves the asset within either the source directory or packages directory
    resolveAsset: (assetName, assetTypes) =>
        -- Cache to reduce lookup times
        searchPaths     = @options\get("searchPaths")
        sourceDirectory = @sourceDirectory

        -- Loop through each registered asset type
        local assetFile, assetPath, searchPath
        for assetExtension, assetType in pairs(assetTypes)
            -- Append the asset type's extension
            assetFile = "#{assetName}.#{assetExtension}"

            -- Return a new Asset instance if it is in the source directory
            assetPath = join(sourceDirectory, assetFile)
            return assetType, assetPath if isFile(assetPath)

            -- Repeat with the remaining search paths
            for searchPath in *searchPaths
                assetPath = join(searchPath, assetFile)
                return assetType, assetPath if isFile(assetPath)

        -- Return nothing since no asset was found
        return nil, nil