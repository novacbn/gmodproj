import open from io

import readFileSync, statSync, writeFileSync from require "fs"
import join from require "path"
import decode, encode from require "json"

import PATH_DIRECTORY_CACHE from "gmodproj/lib/constants"
import hashSHA1 from "gmodproj/lib/digests"
import isFile from "gmodproj/lib/fsx"

-- Asset::Asset()
-- Represents a generic asset type
export class Asset
    -- Asset::new(string assetName, string assetPath)
    -- Constructor for Asset
    new: (assetName, assetPath) =>
        -- Cache the name and path of the asset
        @assetName  = assetName
        @assetPath  = assetPath
        @cachePath  = join(PATH_DIRECTORY_CACHE, hashSHA1(assetName))

    -- Asset::readAsset(boolean isProduction) -> void
    -- Reads an asset into memory and parses it for metadata and transformations
    readAsset: (isProduction) =>
        -- Read the current cached asset data into memory or use dummy data
        assetData = {}
        if isFile(@cachePath) then assetData = decode(readFileSync(@cachePath))

        -- The current asset cache is stale, regenerate it
        modificationTime = statSync(@assetPath).mtime.sec
        unless assetData.path == @assetPath and assetData.mtime == modificationTime
            -- Read the contents of the asset into memory, then pre-collection transform it
            contents    = readFileSync(@assetPath)
            contents    = @preTransform(contents, isProduction)

            -- Regenerate the asset data before caching
            assetData.metadata = @collectMetadata(contents)
            assetData.contents = @postTransform(contents, isProduction)
            assetData.path     = @assetPath
            assetData.mtime    = modificationTime

            -- Write the new asset data to disk cache
            writeFileSync(@cachePath, encode(assetData))

        -- Cache the new data for external access
        @assetData = assetData

    -- Asset::collectMetadata(string contents) -> table
    -- Traverses the asset to collect metadata, e.g. documentation, dependencies
    collectMetadata: (contents) => {
        dependencies:   {},
        documentation:  {}
    }

    -- Asset::preTransform(string contents, boolean isProduction) -> string
    -- Transforms the asset before collecting the metadata
    preTransform: (contents, isProduction) => contents

    -- Asset::postTransform(string contents, boolean isProduction) -> string
    -- Transforms the asset after collecting the metadata
    postTransform: (contents, isProduction) => contents