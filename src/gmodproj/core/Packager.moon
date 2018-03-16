import open from io
import format from string
import insert, remove from table

import basename, join from require "path"

dependency "gmodproj/core/plugins/BuiltinPlugin" -- HAAACKY MCHACKS: this is so the built-in plugin is included within the build
import ConfigurationOptions from "gmodproj/api/ConfigurationOptions"
import Resolver from "gmodproj/core/Resolver"
import logInfo, logFatal from "gmodproj/lib/logging"
import tryImport from "gmodproj/lib/utilities"

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
    configNamespace: "Packager"

    -- PackagerOptions::defaultConfiguration -> table
    -- Represents the default configuration values of the packager type
    defaultConfiguration: {
        minifyProduction: true,

        Plugins: {
            "gmodproj/core/plugins/BuiltinPlugin": {}
        },

        Resolver: {}
    }

    -- PackagerOptions::configurationRules -> table
    -- Represents a LIVR ruleset for validating the configuration
    configurationRules: {
        minifyProduction: {is: "boolean"},

        Plugins: {"any_object"},
        Resolver: {"any_object"}
    }

-- Packager::Packager()
-- Represents a generic Lua output build packager
export class Packager
    -- Packager::new(string sourceDirectory, table option, string parentNamespace?)
    -- Creates the new project manager
    new: (sourceDirectory, options, parentNamespace) =>
        -- Validate the user-provided packager configuration
        @options = PackagerOptions(options, parentNamespace)

        -- Initialize the class variables
        @assetTypes         = {}
        @dependentAssets    = {}
        @loadedAssets       = {}
        @loadedPlugins      = {}

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

        -- Make a new resolver with the loaded asset types
        @resolver = Resolver(sourceDirectory, @assetTypes, @options\get("Resolver"), "#{parentNamespace}.#{PackagerOptions.configNamespace}")

    -- Project::writePackage(table packageBuild, string buildDirectory,  boolean isProduction) -> nil
    -- Writes the build package to disk
    writePackage: (packageBuild, buildDirectory, isProduction) =>
        -- Open the package build and write the package header
        handle = open(join(buildDirectory, packageBuild[2]..".lua"), "wb")
        handle\write(TEMPLATE_PACKAGE_HEADER(packageBuild[1]).."\n")

        -- Add the entry point and loop through the added dependencies
        @addDependency(packageBuild[1])
        dependentAssets = @dependentAssets
        local assetName, assetType, contents
        while #dependentAssets > 0
            -- Resolve the next asset and assert its validity
            assetName = remove(@dependentAssets, 1)
            unless @loadedAssets[assetName]
                loadedAsset = @resolver\resolveAsset(assetName)
                logFatal("asset '#{assetName}' not found!") unless loadedAsset

                -- Read the asset into memory then parse dependent assets
                loadedAsset\readAsset()
                @addDependency(assetName) for assetName in *loadedAsset.assetData.metadata.dependencies

                -- Add asset to package build and log out
                handle\write(TEMPLATE_PACKAGE_MODULE(
                    assetName, loadedAsset.assetData.contents
                )..",\n")

                @loadedAssets[assetName] = true
                logInfo("\t...resolved asset '#{assetName}'")

        -- Write the package footer and close the file
        handle\write(TEMPLATE_PACKAGE_FOOTER())
        handle\close()

    -- Packager::addDependency(string assetName) -> void
    -- Adds a dependency to be added in the build process
    addDependency: (assetName) =>
        -- Insert the dependent asset if it wasn't already
        insert(@dependentAssets, assetName) unless @loadedAssets[assetName]

    -- Packager::registerAsset(string assetExtension, Asset assetType) -> void
    -- Registers an asset type with the active packager
    registerAsset: (assetExtension, assetType) =>
        -- TODO:
        --  base class checking
        --  extension pattern checking
        --  extension already registered checking
        --  check if packager is already processing
        @assetTypes[assetExtension] = assetType