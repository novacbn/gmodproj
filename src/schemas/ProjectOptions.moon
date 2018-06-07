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
        name:        {is: "string", like: PATTERN_METADATA_NAME}
        author:      {is: "string", like: PATTERN_METADATA_NAME}
        version:     {is: "string", like: PATTERN_METADATA_VERSION}
        repository:  {is: "string", like: PATTERN_METADATA_REPOSITORY}

        buildDirectory:     {is: "string"}
        sourceDirectory:    {is: "string"}

        projectBuilds: {
            is_key_pairs: {"string", {"string", "table"}}
        }

        Plugins: {
            is_key_pairs: {"string", "table"}
        }

        Packager:   {"any_object"}
        Resolver:   {"any_object"}
    }

    -- ProjectOptions::default -> table
    -- Represents the default values that are merged before validation
    --
    default: {
        buildDirectory:     "dist"
        sourceDirectory:    "src"

        Plugins: MAP_DEFAULT_PLUGINS
    }
}