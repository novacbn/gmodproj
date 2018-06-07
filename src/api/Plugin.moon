import Object from "novacbn/novautils/utilities/Object"

-- Plugin::Plugin()
-- Represents the base plugin interface extending gmodproj's functionality
-- export
export Plugin = Object\extend {
    -- Plugin::schema -> Schema
    -- Represents the Schema validator for the plugin
    schema: nil

    -- Plugin::constructor(table options)
    -- Constructor for Plugin
    constructor: (options) =>
        -- If a Schema was provided for the Plugin, validate and store the provided options
        if @schema
            @schema.namespace   = "Plugins['"..@schema.namespace.."']"
            @options            = @schema\new(options)

    -- Plugin::registerAssets(Resolver resolver) -> void
    -- Event for registering extra Asset types with gmodproj
    -- event
    registerAssets: (resolver) =>

    -- BuiltinPlugin::registerTemplates(Application application) -> void
    -- Event for registering extra Project Templates with gmodproj
    -- event
    registerTemplates: (application) =>

    -- Plugin::registerPlatforms(Packager packager) -> void
    -- Event for registering extra platform support with gmodproj
    -- event
    registerPlatforms: (packager) =>
}