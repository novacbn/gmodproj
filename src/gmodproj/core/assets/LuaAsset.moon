import gsub, match from string

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
    -- LuaAsset::collectDependencies(string contents) -> void
    -- Traverses the asset to collect dependencies of the Lua script
    collectDependencies: (contents) =>
        -- Collect the dependencies with 'import' and 'dependency' statements
        @scanDependencies(PATTERN_HAS_IMPORTS, PATTERN_EXTRACT_IMPORTS, contents)
        @scanDependencies(PATTERN_HAS_DEPENDENCIES, PATTERN_EXTRACT_DEPENDENCIES, contents)

    -- LuaAsset::scanDependencies(string matchPattern, string extractPattern, string contents) -> void
    -- Scans the asset for dependencies using pattern-matching
    scanDependencies: (matchPattern, extractPattern, contents) =>
        if match(contents, matchPattern)
            gsub(contents, extractPattern, (assetName) -> @addDependency(assetName))