import unpack from _G
import match from string
import insert from table

import readdirSync from require "fs"
import basename, dirname, extname, join from require "path"
import isfileSync from "novacbn/luvit-extras/fs"
import Set from "novacbn/novautils/collections/Set"
import Default, Object from "novacbn/novautils/utilities/Object"

import ResolverOptions from "novacbn/gmodproj/schemas/ResolverOptions"
import PROJECT_PATH from "novacbn/gmodproj/lib/constants"
import makeStringEscape from "novacbn/gmodproj/lib/utilities/string"

-- :: escapePattern(string value) -> string
-- Escapes a string to be Lua-pattern safe
--
escapePattern = makeStringEscape {
    {"%-", "%%-"}
}

-- ::collectFiles(string baseDirectory, table files?, string subDirectory?) -> table
-- Scans the given base directory for files recursively
--
collectFiles = (baseDirectory, files={}, subDirectory) ->
    -- Use the base directory only if a sub directory is not provided
    currentDirectory = subDirectory and join(baseDirectory, subDirectory) or baseDirectory
    for fileName in *readdirSync(currentDirectory)
        -- If the file name is a file, insert it, otherwise recursively walk the directory tree
        if isfileSync(join(currentDirectory, fileName)) then insert(files, subDirectory and subDirectory.."/"..fileName or fileName)
        else collectFiles(baseDirectory, files, subDirectory and subDirectory.."/"..fileName or fileName)

    return files

-- Resolver::Resolver()
-- Represents the asset cache resolver
-- export
export Resolver = Object\extend {
    -- Resolver::registeredAssets -> table
    -- Represents a table of registered asset types
    --
    registeredAssets: Default {}

    -- Resolver::projectPattern -> string
    -- Represents the pattern for matching source directory assets
    --
    projectPattern: nil

    -- Resolver::sourceDirectory -> string
    -- Represents the package's directory of source code
    --
    sourceDirectory: nil

    -- Resolver::constructor(string projectAuthor, string projectName, string sourceDirectory, PluginManager pluginManager, table options?)
    -- Constructor for the package resolver
    --
    constructor: (projectAuthor, projectName, sourceDirectory, pluginManager, options) =>
        -- Validate and configure the Resolver
        @options = ResolverOptions\new(options)

        -- Allow plugins to register extensions to this Resolver
        pluginManager\dispatchEvent("registerAssets", self)

        @projectPrefix      = "#{projectAuthor}/#{projectName}"
        @sourceDirectory    = join(PROJECT_PATH.home, sourceDirectory)

    -- Resolver::resolveAsset(string assetName) -> Asset or nil, string or nil
    -- Resolves the asset within either the source directory or packages directory
    --
    resolveAsset: (assetName) =>
        -- If the asset is from the project, scan the source directory
        projectAsset = match(assetName, "^#{escapePattern(@projectPrefix)}/([%w/%-]+)")
        if projectAsset
            local assetPath
            for assetExtension, assetType in pairs(@registeredAssets)
                assetPath = join(@sourceDirectory, "#{projectAsset}.#{assetExtension}")
                return assetType, assetPath if isfileSync(assetPath)

        -- If asset was not found already, scan the configured search paths
        local assetFile, assetPath
        searchPaths = @options\get("searchPaths")

        for assetExtension, assetType in pairs(@registeredAssets)
            assetFile = "#{assetName}.#{assetExtension}"

            for searchPath in *searchPaths
                assetPath = join(searchPath, assetFile)
                return assetType, assetPath if isfileSync(assetPath)

        -- Return nothing since no asset was found
        return nil, nil

    -- Resolver::resolveAssets() -> table
    -- Resolves a table of valid asset paths and their types
    --
    resolveAssets: () =>
        -- TODO: make less spget

        -- Make a cache of resolved assets
        resolvedAssets = Set\new()

        -- Scan the configured source directory for assets
        local directoryName
        for fileName in *collectFiles(@sourceDirectory)
            for assetExtension, assetType in pairs(@registeredAssets)
                if extname(fileName) == "."..assetExtension
                    directoryName = dirname(fileName)
                    resolvedAssets\push(@projectPrefix.."/"..(directoryName and directoryName.."/"..basename(fileName, "."..assetExtension) or basename(fileName, "."..assetExtension)))

        -- Scan the configured search paths for assets
        searchPaths = @options\get("searchPaths")
        for searchPath in *searchPaths
            for fileName in *collectFiles(searchPath)
                for assetExtension, assetType in pairs(@registeredAssets)
                    if extname(fileName) == "."..assetExtension
                        directoryName = dirname(fileName)
                        resolvedAssets\push(directoryName and directoryName.."/"..basename(fileName, "."..assetExtension) or basename(fileName, "."..assetExtension))

        return resolvedAssets\values()

    -- Resolver::registerAsset(Asset assetType, string assetExtension) -> void
    -- Registers an asset type to the Resolver
    --
    registerAsset: (assetExtension, assetType) =>
        @registeredAssets[assetExtension] = assetType
}