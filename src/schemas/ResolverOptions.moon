import join from require "path"

import Schema from "novacbn/gmodproj/api/Schema"

import PROJECT_PATH from "novacbn/gmodproj/lib/constants"

-- ResolverOptions::ResolverOptions()
-- Represents the LIVR schema for validating 'Resolver' section in 'manifest.gmodproj'
-- export
export ResolverOptions = Schema\extend {
    -- ResolverOptions::namespace -> string
    -- Represents the nested namespace of the schema
    --
    namespace: "Resolver"

    -- ResolverOptions::schema -> table
    -- Represents the LIVR validation schema
    --
    schema: {
        searchPaths: {list_of: {is: "string"}}
    }

    -- ResolverOptions::default -> table
    -- Represents the default values that are merged before validation
    --
    default: {
        searchPaths: {
            join(PROJECT_PATH.home, "packages")
        }
    }
}