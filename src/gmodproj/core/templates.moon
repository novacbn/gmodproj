import format from string
import concat, insert from table

-- ::TEMPLATE_DUMMY_PACKAGE -> template
TEMPLATE_DUMMY_PACKAGE = (projectAuthor, projectName) -> "-- Code within this project can be imported by dependent project that have this installed
-- E.g. If this was exported:
function add(x, y)
    return x + y
end

-- Then project that have this project installed via 'gmodproj install' could import it via:
local #{projectName} = imp".."ort('#{projectAuthor}/#{projectName}/main')
print(#{projectName}.add(1, 2)) -- Prints '3' to console



-- Alternatively, if this package was built with `gmodproj build`, you could import the entire library in Garry's Mod:
local #{projectName} = include('#{projectAuthor}.#{projectName}.lua')
print(#{projectName}.add(1, 2)) -- Prints '3' to console

-- NOTE: when doing this, only the 'main.lua' exports can be used
-- If you were to have this in 'substract.lua':
function substract(a, b)
    return a - b
end

-- You would need to alias the export in 'main.lua' to use it in a standard Garry's Mod script:
exports.substract = imp".."ort('substract')

-- Then in a standard Garry's Mod script:
local #{projectName} = include('#{projectAuthor}.#{projectName}.lua')
print(#{projectName}.substract(3, 1)) -- Prints '2' to console
"

-- ::TEMPLATE_GAMEMODE_MANIFEST -> template
-- Template for creating a Garry's Mod gamemode template
TEMPLATE_GAMEMODE_MANIFEST = (projectName) ->
    -- HACK: would rather use MoonScript's templating, but it only works with double quotes
    return format([["%s"
{
    "base"			"base"
    "title"			"%s"
    "maps"			""
    "menusystem"	"1"

    "settings" {}
}]], projectName, projectName)

-- ::TEMPLATE_PROJECT_BOOTLOADER -> template
-- Template for creating Lua project bootloader
TEMPLATE_PROJECT_BOOTLOADER = (clientFiles, includeFiles) ->
    bootloaderLines = {}

    -- If there are scripts to send to the client, template them
    if clientFiles
        insert(bootloaderLines, "-- These scripts are sent to the client")
        insert(bootloaderLines, "AddCSLuaFile('#{file}')") for file in *clientFiles

    -- If there are scripts to bootload, template them
    if includeFiles
        insert(bootloaderLines, "-- These scripts are bootloaded by this script")
        insert(bootloaderLines, "include('#{file}')") for file in *includeFiles

    -- Combine lines via newline
    return concat(bootloaderLines, "\n")

-- ::addon(string projectAuthor, string projectName, string projectPath) -> void
-- Project creation template for creating Garry's Mod Addons
export addon = (projectAuthor, projectName, projectPath) ->
    -- Create the project directories
    mkdir("addons")
    mkdir("addons/#{projectName}")
    mkdir("addons/#{projectName}/lua")
    mkdir("addons/#{projectName}/lua/autorun")
    mkdir("addons/#{projectName}/lua/autorun/client")
    mkdir("addons/#{projectName}/lua/autorun/server")
    mkdir("src")

    -- Create the Garry's Mod addon manifest
    writeJSON("addons/#{projectName}/addon.json", {
        title:          projectName,
        type:           "",
        tags:           {},
        description:    "",
        ignore:         {}
    })

    -- Create the project's entry points HACK: gmodproj currently doesn't do lexical lookup of import/dependency statements...
    write("src/client.lua", "imp".."ort('shared').sharedFunc()\nprint('I was called on the client!')")
    write("src/server.lua", "imp".."ort('shared').sharedFunc()\nprint('I was called on the server!')")
    write("src/shared.lua", "function sharedFunc()\n\tprint('I was called on the client and server!')\nend")

    -- Create the project's manifest
    writeDataFile("manifest.gmodproj", {
        Project: {
            projectAuthor:  projectAuthor
            projectName:    projectName,

            buildDirectory: "addons/#{projectName}/lua"

            entryPoints: {
                {"client", "autorun/client/#{projectName}.client"},
                {"server", "autorun/server/#{projectName}.server"}
            }
        }
    })

-- ::gamemode(string projectAuthor, string projectName, string projectPath) -> void
-- Project creation template for creating Garry's Mod Gamemodes
export gamemode = (projectAuthor, projectName, projectPath) ->
    -- Create the project directories
    mkdir("gamemodes")
    mkdir("gamemodes/#{projectName}")
    mkdir("gamemodes/#{projectName}/gamemode")
    mkdir("src")

    -- Create the Garry's Mod gamemode manifest
    write("gamemodes/#{projectName}/#{projectName}.txt", TEMPLATE_GAMEMODE_MANIFEST(
        projectName
    ))

    -- Create the Garry's Mod bootloader scripts
    write("gamemodes/#{projectName}/gamemode/cl_init.lua", TEMPLATE_PROJECT_BOOTLOADER(
        nil, {"#{projectName}.client.lua"}
    ))

    write("gamemodes/#{projectName}/gamemode/init.lua", TEMPLATE_PROJECT_BOOTLOADER(
        {"cl_init.lua", "#{projectName}.client.lua"},
        {"#{projectName}.server.lua"}
    ))

    -- Create the project's entry points HACK: gmodproj currently doesn't do lexical lookup of import/dependency statements...
    write("src/client.lua", "imp".."ort('shared').sharedFunc()\nprint('I was called on the client!')")
    write("src/server.lua", "imp".."ort('shared').sharedFunc()\nprint('I was called on the server!')")
    write("src/shared.lua", "function sharedFunc()\n\tprint('I was called on the client and server!')\nend")

    -- Create the project's manifest
    writeDataFile("manifest.gmodproj", {
        Project: {
            projectAuthor:  projectAuthor
            projectName:    projectName,

            buildDirectory: "gamemodes/#{projectName}/gamemode"

            entryPoints: {
                {"client", "#{projectName}.client"},
                {"server", "#{projectName}.server"}
            }
        }
    })

-- ::addon(string projectAuthor, string projectName, string projectPath) -> void
-- Project creation template for creating importable packages
export package = (projectAuthor, projectName, projectPath) ->
    -- Create the project directories
    mkdir("dist")
    mkdir("src")

    -- Create the main file of the project
    write("src/main.lua", TEMPLATE_DUMMY_PACKAGE(
        projectAuthor, projectName
    ))

    -- Create the project's manifest
    writeDataFile("manifest.gmodproj", {
        Project: {
            projectAuthor:  projectAuthor
            projectName:    projectName

            entryPoints: {
                {"main", "#{projectAuthor}.#{projectName}"}
            }
        }
    })