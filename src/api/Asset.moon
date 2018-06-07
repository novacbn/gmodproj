import pcall from _G

import readFileSync, statSync, writeFileSync from require "fs"
import join from require "path"
import decode, encode from "rxi/json/main"

import Object from "novacbn/novautils/utilities/Object"

import PROJECT_PATH from "novacbn/gmodproj/lib/constants"
import hashSHA1 from "novacbn/gmodproj/lib/utilities/openssl"
import logInfo, logWarn from "novacbn/gmodproj/lib/logging"
import isFile from "novacbn/gmodproj/lib/utilities/fs"
import AssetData from "novacbn/gmodproj/schemas/AssetData"

-- Asset::Asset()
-- Represents a generic asset that's processable by gmodproj
-- export
export Asset = Object\extend {
    -- Asset::assetData -> AssetData
    -- Represents the data of the Asset to be serialized
    --
    assetData: nil

    -- Asset::assetName -> string
    -- Represents the import name of the Asset
    --
    assetName: nil

    -- Asset::assetPath -> string
    -- Represents the filesystem path of the Asset
    --
    assetPath: nil

    -- Asset::cachePath -> string
    -- Represents the filesystem path of the Asset within the project's local cache
    --
    cachePath: nil

    -- Asset::canCache -> boolean
    -- Represents if the application is allowing cacheing to disk
    --
    canCache: nil

    -- Asset::isCacheable -> boolean
    -- Represents if the asset can be cached to disk
    --
    isCacheable: true

    -- Asset::isProduction -> boolean
    -- Represents if the application is in production mode
    --
    isProduction: nil

    -- Asset::constructor(string assetName, string assetPath, boolean canCache, boolean isProduction)
    -- Constructor for Asset
    --
    constructor: (@assetName, @assetPath, @canCache, @isProduction) =>
        @cachePath = join(PROJECT_PATH.cache, hashSHA1(@assetName))

    -- Asset::generateAsset() -> void
    -- Reprocesses the asset, regenerating it if cache is stale
    --
    generateAsset: () =>
        -- Check if there was previously loaded asset data
        unless @assetData
            -- If a cache exists and allowed to load, load it into memory
            if @isCacheable and @canCache and isFile(@cachePath)
                assetData           = decode(readFileSync(@cachePath))
                success, assetData  = pcall(AssetData.new, AssetData, assetData)
                if success then @assetData = assetData
                else logWarn("Cache of asset '#{@assetName}' could not be processed, regenerating asset...")

            -- No file cache exists, make dummy data
            @assetData = AssetData\new() unless @assetData

        -- If the cache is stale, regenerate it
        modificationTime = statSync(@assetPath).mtime.sec
        return if @assetPath == @assetData\get("metadata.path") and @assetData\get("metadata.mtime") == modificationTime

        -- Read the asset from disk and perform pretransformation
        contents    = readFileSync(@assetPath)
        contents    = @preTransform(contents)

        -- Collect the relevent metadata of the asset
        collectedDependencies   = @collectDependencies(contents)
        collectDocumentation    = @collectDocumentation(contents)

        -- Perform final transformation on the asset
        contents = @postTransform(contents)

        -- Make new asset data and write to cache
        @assetData = AssetData\new({
            metadata: {
                name:   @assetName
                mtime:  modificationTime
                path:   @assetPath
            }

            dependencies:   collectedDependencies
            exports:        collectedDocumentation
            output:         contents
        })

        -- If the asset is cacheable to disk and application is allowing it, encode asset data to disk
        if @isCacheable and @canCache
            writeFileSync(@cachePath, encode(@assetData.options))

        logInfo("\t...regenerated asset '#{@assetName}'")

    -- Asset::collectDependencies(string contents) -> table
    -- Traverses the asset for the dependencies required by it
    --
    collectDependencies: (contents) => {}

    -- Asset::collectDocumentation(string contents) -> table
    -- Traverses the asset for public-facing documentation of its internals
    --
    collectDocumentation: (contents) => {}

    -- Asset::preTransform(string contents) -> string
    -- Performs first transformation of the asset before collecting metadata
    --
    preTransform: (contents) => contents

    -- Asset::postTransform(string contents) -> string
    -- Performs final transformation on the asset after collecting metadata
    --
    postTransform: (contents) => contents
}