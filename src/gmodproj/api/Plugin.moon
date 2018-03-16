-- Plugin::Plugin()
-- Represents a base plugin class for plugins to use as boilerplate
export class Plugin
    -- Plugin::pluginOptions -> ConfigurationOptions
    -- Represents the options validator of the plugin
    pluginOptions: nil

    -- Plugin::new(table options, string parentNamespace?)
    -- Constructor for Plugin
    new: (options, parentNamespace) =>
        -- If a ConfigurationOptions inherited class is provided, parse the provided options for the plugin
        @options = @pluginOptions(options, parentNamespace) if @pluginOptions

    -- Plugin::registerExtensions(Packager packager) -> nil
    -- Event for registering the plugin's extensions with the active Packager
    registerExtensions: (packager) =>