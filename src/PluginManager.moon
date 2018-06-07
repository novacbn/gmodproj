import loadstring, pairs, pcall from _G

import readFileSync from require "fs"
import join from require "path"

import Default, Object from "novacbn/novautils/utilities/Object"

import APPLICATION_CORE_VERSION, PROJECT_PATH, USER_PATH from "novacbn/gmodproj/lib/constants"
import logFatal from "novacbn/gmodproj/lib/logging"
import isFile from "novacbn/gmodproj/lib/utilities/fs"

-- ::loadPlugin(string pluginName) -> table or nil, string or nil
-- Loads the plugin and returns its exports table
--
loadPlugin = (pluginName) ->
    -- Try to load the plugin from the project installed plugins
    pluginPath = join(PROJECT_PATH.plugins, pluginName)..".lua"
    if isFile(pluginPath)
        contents            = readFileSync(pluginPath)
        pluginChunk, err    = loadstring(contents, "project-plugin:"..pluginName)

        -- If the plugin loads, execute the code chunk, otherwise return the error
        return pluginChunk(), nil if pluginChunk
        return nil, err

    -- Try to load the plugin from the globally installed plugins
    pluginPath = join(USER_PATH.plugins, pluginName)..".lua"
    if isFile(pluginPath)
        contents            = readFileSync(pluginPath)
        pluginChunk, err    = loadstring(contents, "user-plugin:"..pluginName)

        -- If the plugin loads, execute the code chunk, otherwise return the error
        return pluginChunk(), nil if pluginChunk
        return nil, err

    -- Try to load the plugin from bundled plugins
    success, exports = pcall(require, "plugins/"..pluginName)
    return exports, nil if success
    return nil, exports

-- PluginManager::PluginManager()
-- Represents a plugin manager to load and configure plugins
-- export
export PluginManager = Object\extend {
    -- PluginManager::loadedPlugins -> table
    -- Represents the currently loaded user plugins
    --
    loadedPlugins: Default {}

    -- PluginManager::constructor()
    -- Constructor for PluginManager
    --
    constructor: (pluginMap) =>
        local pluginExports, pluginError
        for pluginName, pluginOptions in pairs(pluginMap)
            -- Try to load the specified plugin
            pluginExports, pluginError = loadPlugin(pluginName)
            logFatal("plugin '#{pluginName}' could not be loaded:\n#{pluginError}") unless pluginExports

            -- Initialize the successfully loaded plugin
            @loadedPlugins[pluginName] = pluginExports.Plugin\new(pluginOptions)

    -- PluginManager::dispatchEvent(string eventName, any ...) -> void
    -- Dispatches the specified event to all loaded plugins with the provided varargs
    --
    dispatchEvent: (eventName, ...) =>
        -- Dispatch the event and arguments to all loaded plugins
        for pluginName, pluginObject in pairs(@loadedPlugins)
            pluginObject[eventName](pluginObject, ...)         
}

-- Export interface for plugins
_G.gmodproj = {
    api: {
        Asset:          dependency("novacbn/gmodproj/api/Asset").Asset
        DataAsset:      dependency("novacbn/gmodproj/api/DataAsset").DataAsset
        Platform:       dependency("novacbn/gmodproj/api/Platform").Platform
        Plugin:         dependency("novacbn/gmodproj/api/Plugin").Plugin
        ResourceAsset:  dependency("novacbn/gmodproj/api/ResourceAsset").ResourceAsset
        Schema:         dependency("novacbn/gmodproj/api/Schema").Schema
        Template:       dependency("novacbn/gmodproj/api/Template").Template
    }

    -- Allow for plugins to import assets from gmodproj's own build
    require: dependency

    version: APPLICATION_CORE_VERSION
}