import Schema from "novacbn/gmodproj/api/Schema"

import MAP_DEFAULT_PLUGINS from "novacbn/gmodproj/lib/constants"

-- ::PATTERN_METADATA_NAME -> string
-- Represents a pattern to validate names that should be dashes and lowercase alphanumeric only, my-name
-- export
export PATTERN_METADATA_NAME = "^%l[%l%d%-]*$"

-- ::PATTERN_METADATA_REPOSITORY -> string
-- Represents a pattern to validate URIs, e.g. protocol://delimited/parts
-- export
export PATTERN_METADATA_REPOSITORY = "^[%w]+://[%w%./%-]+$"
-- NOTE: ^this pattern probably has edge cases not considering

-- ::PATTERN_METADATA_VERSION -> string
-- Represents a pattern to validate SemVer version strings, e.g. 0.2.1
-- export
export PATTERN_METADATA_VERSION = "^[%d]+.[%d]+.[%d]+$"

-- ProjectOptions::ProjectOptions()
-- Represents the LIVR schema for validating 'manifest.gmodproj'
-- export
export ProjectOptions = Schema\extend {
    -- ProjectOptions::schema -> table
    -- Represents the LIVR validation schema
    --
    schema: {
        Project: {
            nested_object: {
                projectName:        {is: "string", like: PATTERN_METADATA_NAME}
                projectAuthor:      {is: "string", like: PATTERN_METADATA_NAME}
                projectVersion:     {is: "string", like: PATTERN_METADATA_VERSION}
                projectRepository:  {is: "string", like: PATTERN_METADATA_REPOSITORY}

                buildDirectory:     {is: "string"}
                sourceDirectory:    {is: "string"}

                entryPoints: {
                    min_items: 1

                    list_of: {
                        list_of: {is: "string"}
                    }
                }

                Packager:   {"any_object"}
                Plugins:    {"any_object"} -- TODO: string->table keypair checks
                Resolver:   {"any_object"}
                Scripts:    {"any_object"} -- TODO: string->string/function keypair checks
            }
        }
    }

    -- ProjectOptions::default -> table
    -- Represents the default values that are merged before validation
    --
    default: {
        Project: {
            buildDirectory:     "dist"
            sourceDirectory:    "src"

            Plugins: MAP_DEFAULT_PLUGINS
        }
    }
}