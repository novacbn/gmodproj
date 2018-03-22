import open from io

import basename from require "path"

dependency "gmodproj/core/plugins/BuiltinPlugin" -- HAAACKY MCHACKS: this is so the built-in plugin is included within the build
import ConfigurationOptions from "gmodproj/api/ConfigurationOptions"
import logInfo, logFatal from "gmodproj/lib/logging"
import tryImport from "gmodproj/lib/utilities"
import Set from "gmodproj/lib/collections/Set"

-- ::TEMPLATE_PACKAGE_HEADER -> template
-- Header project build code for managing virtual dependencies
TEMPLATE_PACKAGE_HEADER = (entryPoint) -> "return (function (modules, ...)
    local _G            = _G
    local error         = _G.error
    local setfenv       = _G.setfenv
    local setmetatable  = _G.setmetatable

    local moduleCache = {}

    local function makeEnvironment(moduleChunk)
        local exports = {}

        local moduleEnvironment = setmetatable({}, {
            __index = function (self, key)
                if exports[key] ~= nil then
                    return exports[key]
                end

                return _G[key]
            end,

            __newindex = exports
        })

        return setfenv(moduleChunk, moduleEnvironment), exports
    end

    local function makeReadOnly(tbl)
        return setmetatable({}, {
            __index = tbl,
            __newindex = function (self, key, value) error(\"module 'exports' table is read only\") end
        })
    end

    local import = nil
    function import(moduleName, ...)
        local moduleChunk = modules[moduleName]
        if not moduleChunk then error(\"bad argument #1 to 'import' (invalid module, got '\"..moduleName..\"')\") end

        if not moduleCache[moduleName] then
            local moduleEnvironment, exports = makeEnvironment(moduleChunk)
            moduleEnvironment(exports, import, import, ...)
            moduleCache[moduleName] = makeReadOnly(exports)
        end

        return moduleCache[moduleName]
    end

    return import('#{entryPoint}', ...)
end)({"

-- ::TEMPLATE_PACKAGE_MODULE -> template
-- Template for packaging a module into the build
TEMPLATE_PACKAGE_MODULE = (assetName, moduleBody) -> "['#{assetName}'] = function (exports, import, dependency, ...)
#{moduleBody}
end"

-- Template for requiring the project's entry point and returning the exports
TEMPLATE_PACKAGE_FOOTER = () -> "}, ...)"

-- PackagerOptions::PackagerOptions()
-- Represents the configuration options of the packager
class PackagerOptions extends ConfigurationOptions
    -- PackagerOptions::configNamespace -> string
    -- Represents the namespace path of this configuration
    configNamespace: "Project.Packager"

    -- PackagerOptions::defaultConfiguration -> table
    -- Represents the default configuration values of the packager type
    defaultConfiguration: {
        minifyProduction: true,

        Plugins: {
            "gmodproj/core/plugins/BuiltinPlugin": {}
        }
    }

    -- PackagerOptions::configurationRules -> table
    -- Represents a LIVR ruleset for validating the configuration
    configurationRules: {
        minifyProduction: {is: "boolean"},

        Plugins: {"any_object"}
    }

-- Packager::Packager()
-- Represents a generic Lua output build packager
export class Packager
    -- Packager::assetTypes -> table
    -- Represents the registered Asset classes used for packaging
    assetTypes: nil

    -- Packager::pendingAssets -> Set
    -- Represents the assets pending to be packaged into the build
    pendingAssets: nil

    -- Packager::resolver -> Resolver
    -- Represents the resolver used during the packaging process
    resolver: nil

    -- Packager::new(Resolver resolver, table options?)
    -- Creates the new project manager
    new: (resolver, options) =>
        -- Validate the user-provided packager configuration
        @options = PackagerOptions(options)

        -- Initialize the class variables
        @assetTypes     = {}
        @loadedPlugins  = {}

        -- Loop through the provided plugins and initialize them
        local pluginClass
        for pluginName, pluginOptions in pairs(@options\get("Plugins"))
            -- Try to import the specified plugin, bailout if unsuccessful
            success, pluginClass = tryImport(pluginName, basename(pluginName))
            logFatal("Plugin '#{pluginName}' could not be imported:\n#{pluginClass}") unless success

            -- Initialize the plugin and cache it
            @loadedPlugins[pluginName] = pluginClass(pluginOptions, "#{parentNamespace}.#{PackagerOptions.configNamespace}.Plugins")

        -- Loop through the loaded plugins and register their extensions
        for pluginName, plugin in pairs(@loadedPlugins)
            plugin\registerExtensions(self) -- seems redundent, maybe move to Plugin class' new method

        -- Cache the provided resolver
        @resolver = resolver

    -- Project::writePackage(string entryPoint, string endPoint, boolean isProduction) -> nil
    -- Writes the build package to disk
    writePackage: (entryPoint, endPoint, isProduction) =>
        -- Open the package build and write the package header
        handle = open(endPoint, "wb")
        handle\write(TEMPLATE_PACKAGE_HEADER(entryPoint).."\n")

        -- Make fresh set of dependencies and add the initial entry point
        @pendingAssets = Set()
        @addDependency(entryPoint)

        -- Loop through each asset pending for packaging
        local assetType, assetPath, loadedAsset
        for _, assetName in @pendingAssets\iter()
            -- Resolve the asset and validate it
            assetType, assetPath = @resolver\resolveAsset(assetName, @assetTypes)
            logFatal("Asset '#{assetName}' not found!") unless assetType

            -- Read and transform the asset into a module to package it
            loadedAsset = assetType(assetName, assetPath, self)
            handle\write(TEMPLATE_PACKAGE_MODULE(
                assetName, loadedAsset\readAsset()
            )..",\n")

            logInfo("\t...resolved asset '#{assetName}'")

        -- Write the package footer and close the file
        handle\write(TEMPLATE_PACKAGE_FOOTER())
        handle\close()

    -- Packager::addDependency(string assetName) -> void
    -- Adds an asset to be processed in the build process
    addDependency: (assetName) =>
        -- Add the asset to the dependency Set
        @pendingAssets\add(assetName)

    -- Packager::registerAsset(string assetExtension, Asset assetType) -> void
    -- Registers an asset type with the Packager
    registerAsset: (assetExtension, assetType) =>
        -- TODO:
        --  base class checking
        --  extension pattern checking
        --  extension already registered checking
        --  check if packager is already processing
        @assetTypes[assetExtension] = assetType