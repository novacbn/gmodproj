import parse from require "toml"

import DataAsset from "gmodproj/api/DataAsset"

-- TOMLAsset::TOMLAsset()
-- Represents a generic TOML asset that can be imported
export class TOMLAsset extends DataAsset
    -- TOMLAsset::preTransform(string contents, boolean isProduction) -> string
    -- Decodes the TOML asset into a Lua Table for later encoding into a Lua Table string
    preTransform: (contents, isProduction) => parse(contents)