import unpack from _G
import match from string
import insert, sort from table

import writeFileSync from require "fs"

import globtopattern from "davidm/globtopattern/main"
import mapi from "novacbn/novautils/table"
import Set from "novacbn/novautils/collections/Set"
import WriteBuffer from "novacbn/novautils/io/WriteBuffer"
import Default, Object from "novacbn/novautils/utilities/Object"

import logInfo, logFatal from "novacbn/gmodproj/lib/logging"
import PackagerOptions from "novacbn/gmodproj/schemas/PackagerOptions"

-- Packager::Packager()
-- Represents the Packager for building distributables for projects
-- export
export Packager = Object\extend {
    -- Packager::canCache -> boolean
    -- Represents if the application is allowing assets to cache to disk
    --
    canCache: false

    -- Packager::excludedAssets -> table
    -- Represents all a table of Lua patterns to exclude sets of asset import paths
    --
    excludedAssets: nil

    -- Packager::flags -> table
    -- Represents the commands flags passed to the application
    --
    flags: nil

    -- Packager::isProduction -> boolean
    -- Represents if the application is in production mode
    --
    isProduction: nil

    -- Packager::loadedAssets -> table
    -- Represents the previously loaded assets
    --
    loadedAssets: Default {}

    -- Packager::registeredPlatforms -> table
    -- Represents the targetable Platforms registered to the Packager
    --
    registeredPlatforms: Default {}

    -- Packager::resolver -> Resolver
    -- Represents the active Resolver to be used in the packaging process
    --
    resolver: nil

    -- Packager::targetPlatform -> Platform
    -- Represents the platform being targeted for the build
    --
    targetPlatform: nil

    -- Packager::constructor(boolean isProduction, table flags, Resolver resolver, PluginManager pluginManager, table options?) -> void
    -- Constructor for Packager
    --
    constructor: (@isProduction, flags, @resolver, pluginManager, options) =>
        -- Validate the Packager options
        options = PackagerOptions\new(options)

        -- Precompile all the inclusion and exclusion globs
        @includedAssets = mapi(options\get("includedAssets"), (i, v) -> globtopattern(v))
        @excludedAssets = mapi(options\get("excludedAssets"), (i, v) -> globtopattern(v))

        -- Allow application flags to determine if assets can cache to disk
        @canCache = not (flags["-nc"] or flags["--no-cache"])

        -- Allow plugins to register extensions to this Packager
        pluginManager\dispatchEvent("registerPlatforms", self)

        -- Retrieve and validate the targeted platform's generator
        targetPlatform = @registeredPlatforms[options\get("targetPlatform")]
        logFatal("cannot target platform '#{targetPlatform}'") unless targetPlatform
        @targetPlatform = targetPlatform\new(isProduction)

    -- Packager::collectDependencies(table defaultAssets) -> table
    -- Walks the asset dependency tree, starting with the provided assets
    --
    collectDependencies: (defaultAssets) =>
        -- Make new Set with the default assets
        collectedDependencies   = Set\fromTable(defaultAssets)
        excludedAssets          = @excludedAssets

        local assetType, assetPath, loadedAsset, excludedAsset
        for assetName in collectedDependencies\iter()
            -- If not previously loaded into cache, do a fresh resolve the asset
            unless @loadedAssets[assetName]
                assetType, assetPath = @resolver\resolveAsset(assetName)
                logFatal("asset '#{assetName}' could not be resolved") unless assetType
                @loadedAssets[assetName] = assetType\new(assetName, assetPath, @canCache, @isProduction)

            -- Regenerate the asset for any potential changes
            loadedAsset = @loadedAssets[assetName]
            loadedAsset\generateAsset()

            -- Add the asset's dependencies into the set
            for assetName in *loadedAsset.assetData\get("dependencies")
                -- Resolve if the dependency is excluded from packaging
                excludedAsset = false
                for assetPattern in *excludedAssets
                    if match(assetName, assetPattern)
                        excludedAsset = true
                        break
                
                collectedDependencies\push(assetName) unless excludedAsset

        -- Convert to table and sort the dependencies
        collectedDependencies = collectedDependencies\values()
        sort(collectedDependencies)
        return collectedDependencies

    -- Packager::registerPlatform(string platformName, Platform platform) -> void
    -- Registers a platform that's able to be targeted
    --
    registerPlatform: (platformName, platform) =>
        @registeredPlatforms[platformName] = platform

    -- Packager::Packager(string entryPoint, string endPoint) -> void
    -- Packages up the project into a distributable file for the target platform
    --
    writePackage: (entryPoint, endPoint) =>
        -- By default, include the entry point asset
        defaultAssets = {entryPoint}

        -- If there are other assets to include by default, scan the project directories
        if #@includedAssets > 0
            for assetName in *@resolver\resolveAssets()
                for assetPattern in *@includedAssets
                    insert(defaultAssets, assetName) if match(assetName, assetPattern)

        -- Start the virtual buffer and write the target platform's package header
        buffer = WriteBuffer\new()
        buffer\writeString(@targetPlatform\generatePackageHeader(entryPoint))

        -- Walk the entry point's dependency tree and write each asset to the package
        local loadedAsset
        for assetName in *@collectDependencies(defaultAssets)
            loadedAsset = @loadedAssets[assetName]
            buffer\writeString(@targetPlatform\generatePackageModule(
                assetName, loadedAsset.assetData\get("output")
            ))

        -- Write the target platform's packager footer
        buffer\writeString(@targetPlatform\generatePackageFooter())

        -- Perform final package transformation then write to end point file
        contents = @targetPlatform\transformPackage(buffer\toString())
        writeFileSync(endPoint, contents)
}