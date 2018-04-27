import Schema from "novacbn/gmodproj/api/Schema"

-- AssetData::AssetData()
-- Represents the data of a cached asset
-- export
export AssetData = Schema\extend {
    -- AssetData::schema -> table
    -- Represents the LIVR validation schema
    schema: {
        metadata: {
            nested_object: {
                name: {is: "string"}
                mtime: {is: "number"}
                path: {is: "string"}
            }
        }

        dependencies: {
            list_of: {
                is: "string"
            }
        }

        -- TODO: proper validation of exports object
        exports: {"any_object"}

        output: {is: "string"}
    }

    -- AssetData::default -> table
    -- Represents the default values that are merged before validation
    --
    default: {
        metadata: {
            name: ""
            mtime: 0
            path: ""
        },

        dependencies:   {}
        exports:        {}

        output: ""
    }
}