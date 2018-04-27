import Schema from "novacbn/gmodproj/api/Schema"

-- PackagerOptions::PackagerOptions()
-- Represents the LIVR schema for validating 'Packager' section in 'manifest.gmodproj'
-- export
export PackagerOptions = Schema\extend {
    -- PackagerOptions::namespace -> string
    -- Represents the nested namespace of the schema
    --
    namespace: "Project.Packager"

    -- PackagerOptions::schema -> table
    -- Represents the LIVR validation schema
    --
    schema: {
        excludedAssets: {
            list_of: {is: "string"}
        }

        includedAssets: {
            list_of: {is: "string"}
        }

        targetPlatform: {is: "string"}
    }

    -- PackagerOptions::default -> table
    -- Represents the default values that are merged before validation
    --
    default: {
        excludedAssets: {}
        includedAssets: {}
        targetPlatform: "garrysmod"
    }
}