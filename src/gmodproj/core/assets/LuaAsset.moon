import pairs from _G
import gsub, match from string

import merge from require "glue"

import Asset from "gmodproj/api/Asset"

-- ::PATTERN_HAS_IMPORTS -> pattern
-- Represents a pattern to check if a script has 'import' statements
PATTERN_HAS_IMPORTS = "import"

-- ::PATTERN_HAS_DEPENDENCIES -> pattern
-- Represents a pattern to check if a script has 'dependency' statements
PATTERN_HAS_DEPENDENCIES = "dependency"

-- ::PATTERN_EXTRACT_IMPORTS -> pattern
-- Represents a pattern to extract 'import' statements
PATTERN_EXTRACT_IMPORTS = "import[\\(]?[%s]*['\"]([%w/_]+)['\"]"

-- ::PATTERN_EXTRACT_DEPENDENCIES -> pattern
-- Represents a pattern to extract 'dependency' statements
PATTERN_EXTRACT_DEPENDENCIES = "dependency[\\(]?[%s]*['\"]([%w/_]+)['\"]"

-- LuaAsset::LuaAsset()
-- Represents a Lua asset
export class LuaAsset extends Asset
    -- LuaAsset::collectDependencies(string matchPattern, string extractPattern, string contents) -> table or nil
    -- Collects the list of dependencies within a Lua script
    collectDependencies: (matchPattern, extractPattern, contents) =>
        if match(contents, matchPattern)
            collectedDependencies = {}
            gsub(contents, extractPattern, (assetName) ->
                collectedDependencies[assetName] = true
            )

            return collectedDependencies

        return nil

    -- LuaAsset::collectMetadata(string contents) -> table
    -- Traverses the asset to collect metadata, e.g. documentation, dependencies
    collectMetadata: (contents) =>
        -- Collect the asset dependencies with both statement types
        collectedDependencies = {}
        merge(collectedDependencies, @collectDependencies(PATTERN_HAS_IMPORTS, PATTERN_EXTRACT_IMPORTS, contents) or {})
        merge(collectedDependencies, @collectDependencies(PATTERN_HAS_DEPENDENCIES, PATTERN_EXTRACT_DEPENDENCIES, contents) or {})
        collectedDependencies = [assetName for assetName, _ in pairs(collectedDependencies)]

        -- Return the asset metadata
        return {
            dependencies:   collectedDependencies,
            documentation:  {}
        }