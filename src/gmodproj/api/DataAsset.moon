import block from require "serpent"

import Asset from "gmodproj/api/Asset"

-- ::TEMPLATE_MODULE_LUA -> template
-- Template for packaging a table of data into Lua code
TEMPLATE_MODULE_LUA = (assetName, luaTable) -> "exports['#{assetName}'] = #{luaTable}"

-- DataAsset::DataAsset()
-- Represents a generic asset that encodes preprocessed data into a importable Lua module
export class DataAsset extends Asset
    -- JSONAsset::preTransform(string contents, boolean isProduction) -> string
    -- Decodes the asset into a Lua Table for later encoding into a Lua Table string
    preTransform: (contents, isProduction) => contents

    -- JSONAsset::postTransform(string contents, boolean isProduction) -> string
    -- Encodes the asset into a Lua Table string after decoding the base asset
    postTransform: (contents, isProduction) =>
        -- Dump the contents into a Lua Table string, then template it
        luaTable = block(contents, {
            comment: false
        })

        return TEMPLATE_MODULE_LUA(@assetName, luaTable)