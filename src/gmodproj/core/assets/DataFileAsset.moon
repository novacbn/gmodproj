import DataAsset from "gmodproj/api/DataAsset"
import fromString from "gmodproj/lib/datafile"

-- DataFileAsset::DataFileAsset()
-- Represents a generic DataFile asset that can be imported
export class DataFileAsset extends DataAsset
    -- DataFileAsset::preTransform(string contents, boolean isProduction) -> string
    -- Decodes the DataFile asset into a Lua Table for later encoding into a Lua Table string
    preTransform: (contents, isProduction) => fromString(contents)