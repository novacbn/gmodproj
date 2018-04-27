import basename from require "path"

import block from "pkulchenko/serpent/main"

import Asset from "novacbn/gmodproj/api/Asset"

-- ::TEMPLATE_MODULE_LUA(string assetName, string luaTable) -> string
-- Templates a stringified-table for packaging into importable Lua code
--
TEMPLATE_MODULE_LUA = (assetName, luaTable) -> "exports['#{basename(assetName)}'] = #{luaTable}"

-- DataAsset::DataAsset()
-- Represents a generic asset that encodes preprocessed data into a importable Lua table
-- export
export DataAsset = Asset\extend {
    -- DataAsset::postTransform(string contents) -> string
    -- Encodes an table into a Lua asset exporting a importable Lua table
    postTransform: (contents) =>
        -- Dump the contents into a Lua Table string, then template it
        luaTable = block(contents, {
            comment: false
        })

        return TEMPLATE_MODULE_LUA(@assetName, luaTable)
}