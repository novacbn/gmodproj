import open from io

import readFileSync, statSync, writeFileSync from require "fs"
import join from require "path"
import decode, encode from require "json"

import PATH_DIRECTORY_CACHE from "gmodproj/lib/constants"
import hashSHA1 from "gmodproj/lib/digests"
import isFile from "gmodproj/lib/fsx"
import Set from "gmodproj/lib/collections/Set"

-- Asset::Asset()
-- Represents a generic asset type
export class Asset
    -- Asset:assetData -> table
    -- Represents a generic table of data related to the Asset that will be serialized
    assetData: nil

    -- Asset::assetName -> string
    -- Represents the import name of the Asset
    assetName: nil

    -- Asset::assetPath -> string
    -- Represents the canonical file path of the Asset
    assetPath: nil

    -- Asset::cachePath -> string
    -- Represents the canonical file path of the Asset within the project's cache
    cachePath: nil

    -- Asset::packager -> Packager
    -- Represents the running Packager that the Asset belongs to
    packager: nil

    -- Asset::new(string assetName, string assetPath, Packager packager)
    -- Constructor for Asset
    new: (assetName, assetPath, packager) =>
        -- Cache the provided arguments
        @assetData  = {}
        @assetName  = assetName
        @assetPath  = assetPath
        @cachePath  = join(PATH_DIRECTORY_CACHE, hashSHA1(assetName))
        @packager   = packager

        -- Create the default dummy asset data
        @assetData = {
            metadata: {}
        }

    -- Asset::readAsset(boolean isProduction) -> string
    -- Reads an asset into memory and processes it with transformations and metadata collection
    readAsset: (isProduction) =>
        -- Read the current cached asset data into memory or use dummy data
        if isFile(@cachePath) then @assetData = decode(readFileSync(@cachePath))

        -- If the current asset cache is stale, regenerate it
        modificationTime = statSync(@assetPath).mtime.sec
        unless @assetData.path == @assetPath and @assetData.mtime == modificationTime
            -- Read the contents of the asset into memory, then pre-collection transform it
            contents    = readFileSync(@assetPath)
            contents    = @preTransform(contents, isProduction)

            -- Reset the stale metadata and recollect the asset's metadata
            @assetData.metadata = {}
            @collectDependencies(contents)

            -- Regenerate the asset for future incremental builds
            @assetData.contents = @postTransform(contents, isProduction)
            @assetData.path     = @assetPath
            @assetData.mtime    = modificationTime

            @assetData.metadata.dependencies = @assetData.metadata.dependencies\values() if @assetData.metadata.dependencies

            -- Write the new asset data to disk cache
            writeFileSync(@cachePath, encode(@assetData))

        else
            -- If the asset isn't stale, add the required metadata to the running Packager
            if @assetData.metadata.dependencies
                @packager\addDependency(assetName) for assetName in *@assetData.metadata.dependencies

        -- Return the contents of the asset for processing
        return @assetData.contents

    -- Asset::addDependency(string assetName) -> void
    -- Adds the asset to the asset and packager
    addDependency: (assetName) =>
        -- If the asset does not currently have a dependency table, make it
        @assetData.metadata.dependencies = Set() unless @assetData.metadata.dependencies

        -- Add the dependency to the asset's metadata and packager
        @assetData.metadata.dependencies\add(assetName)
        @packager\addDependency(assetName)

    -- Asset::collectDependencies(string contents) -> void
    -- Traverses the asset to collect dependencies of the asset
    collectDependencies: (contents) =>

    -- Asset::preTransform(string contents, boolean isProduction) -> string
    -- Transforms the asset before collecting the metadata
    preTransform: (contents, isProduction) => contents

    -- Asset::postTransform(string contents, boolean isProduction) -> string
    -- Transforms the asset after collecting the metadata
    postTransform: (contents, isProduction) => contents