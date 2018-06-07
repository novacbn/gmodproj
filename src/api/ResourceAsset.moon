import basename from require "path"

import Asset from "novacbn/gmodproj/api/Asset"
import toByteString from "novacbn/gmodproj/lib/utilities/string"

-- ::TEMPLATE_MODULE_LUA(string assetName, string byteString) -> string
-- Templates a resource asset into Lua module the parsed a byte string
TEMPLATE_MODULE_LUA = (assetName, byteString) -> "local byteTable     = #{byteString}
local string_char   = string.char
local table_concat  = table.concat

for index, byte in ipairs(byteTable) do
    byteTable[index] = string_char(byte)
end

exports['#{basename(assetName)}'] = table_concat(byteTable, '')"

-- ResourceAsset::ResourceAsset()
-- Represents a generic asset that is encoded as a byte string, useful for plaintext/binary assets that are not Lua code
export ResourceAsset = Asset\extend {
    -- ResourceAsset::postTransform(string contents) -> string
    -- Packages the asset as a Lua readable byte string
    postTransform: (contents) =>
        -- Transform the asset into a byte string and template it
        return TEMPLATE_MODULE_LUA(@assetName, toByteString(contents))
}