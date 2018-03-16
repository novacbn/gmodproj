import decode from require "json"

import DataAsset from "gmodproj/api/DataAsset"

-- JSONAsset::JSONAsset()
-- Represents a generic JSON asset that can be imported
export class JSONAsset extends DataAsset
    -- JSONAsset::preTransform(string contents, boolean isProduction) -> string
    -- Decodes the JSON asset into a Lua Table for later encoding into a Lua Table string
    preTransform: (contents, isProduction) => decode(contents)