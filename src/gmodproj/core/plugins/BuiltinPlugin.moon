import Plugin from "gmodproj/api/Plugin"
import DataFileAsset from "gmodproj/core/assets/DataFileAsset"
import JSONAsset from "gmodproj/core/assets/JSONAsset"
import LuaAsset from "gmodproj/core/assets/LuaAsset"
import MoonAsset from "gmodproj/core/assets/MoonAsset"
import TOMLAsset from "gmodproj/core/assets/TOMLAsset"
--import JavaScriptAsset from "gmodproj/core/assets/JavaScriptAsset"

-- BuiltinPlugin::BuiltinPlugin()
-- Represents the plugin providing built-in functionality to the command-line application
export class BuiltinPlugin extends Plugin
    -- BuiltinPlugin::registerExtensions(Packager packager) -> nil
    -- Event for registering the plugin's extensions with the active Packager
    registerExtensions: (packager) =>
        -- Register the built-in scripting language support
        packager\registerAsset("lua", LuaAsset)
        packager\registerAsset("moon", MoonAsset)

        -- Register the built-in flatfile data support
        packager\registerAsset("datl", DataFileAsset)
        packager\registerAsset("json", JSONAsset)
        packager\registerAsset("toml", TOMLAsset)

        -- Register the built-in resource asset support
        --packager\registerAsset("js", JavaScriptAsset)