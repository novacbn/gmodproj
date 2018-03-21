import match, gsub from string

import format_error, tree from require "moonscript/compile"
import string from require "moonscript/parse"

import LuaAsset from "gmodproj/core/assets/LuaAsset"
import logFatal from "gmodproj/lib/logging"

-- ::PATTERN_HAS_IMPORTS -> pattern
-- Represents a pattern for checking if the MoonScript has imports declarations
PATTERN_HAS_IMPORTS = "import"

-- ::PATTERN_EXTRACT_IMPORTS -> pattern
-- Represents a pattern to extract imports from a MoonScript for transformation
PATTERN_EXTRACT_IMPORTS = "(import[%s]+[%w_,%s]+[%s]+from[%s]+)(['\"][%w/_]+['\"])"

-- MoonAsset::MoonAsset()
-- Represents a MoonScript asset
export class MoonAsset extends LuaAsset
    -- MoonAsset::transformImports(string contents) -> string
    -- Transforms all 'import X from "Y"' statements into 'import X from dependency("Y")'
    transformImports: (contents) =>
        -- If the MoonScript has import statements, convert then
        if match(contents, PATTERN_HAS_IMPORTS)
            return gsub(contents, PATTERN_EXTRACT_IMPORTS, (importStatement, assetName) ->
                -- Append the new source of import to the statement
                return importStatement.."dependency(#{assetName})"
            )

        return contents

    -- MoonAsset::preTransform(string contents, boolean isProduction) -> string
    -- Transforms a MoonScript asset into Lua before dependency collection
    preTransform: (contents, isProduction) =>
        -- Transform the MoonScript string import statements
        contents = @transformImports(contents)

        -- Parse the script into an abstract syntax tree and assert for errors
        syntaxTree, err = string(contents)
        logFatal("Failed to parse asset '#{@assetName}': #{err}") unless syntaxTree

        -- Compile the syntax tree into valid Lua code and again assert for errors
        luaCode, err, pos = tree(syntaxTree)
        logFatal("Failed to compile asset '#{@assetName}': #{format_error(err, pos, contents)}") unless luaCode
        return luaCode