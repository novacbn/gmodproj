import unpack from _G

import pack from "novacbn/novautils/utilities"

import logInfo from "novacbn/gmodproj/lib/logging"
import ResolverOptions from "novacbn/gmodproj/schemas/ResolverOptions"
import readManifest from "novacbn/gmodproj/lib/utilities"
import watchPath from "novacbn/gmodproj/lib/utilities/fs"
bin     = dependency "novacbn/gmodproj/commands/bin"
build   = dependency "novacbn/gmodproj/commands/build"

-- ::makeBinding(Options options, string script, string ...) -> function
-- Make a bound function depending on if a script is specified
--
makeBinding = (options, script, ...) ->
    if script then
        args = pack(...)
        return -> bin.executeCommand(options, script, unpack(args))

    return -> build.executeCommand(options, "development")

-- ::TEXT_COMMAND_DESCRIPTION -> string
-- Represents the description of the command
-- export
export TEXT_COMMAND_DESCRIPTION = "Watches the project for changes and rebuilds"

-- ::TEXT_COMMAND_SYNTAX -> string
-- Represents the syntax of the command
-- export
export TEXT_COMMAND_SYNTAX = "[script] [...args]"

-- ::TEXT_COMMAND_EXAMPLES -> string
-- Represents the examples of the command
-- export
export TEXT_COMMAND_EXAMPLES = {
    ""
    "build development"
}

-- ::configureCommand(Options options) -> void
-- Configures the input of the command
-- export
export configureCommand = (options) ->
    with options
        \boolean "watch-search", "Watches configured search pathes in the project manifest"

-- ::executeCommand(Options options, string script?) -> void
-- Watches the project's source directory, and search paths if specified, for rebuilding
-- export
export executeCommand = (flags, script, ...) ->
    manifest = readManifest()

    -- Retrieve the 'gmodproj bin [script] [...]' binding if a script is specified, otherwise use a 'gmodproj build development' binding
    modificationBind = makeBinding(flags, script, ...)

    -- Start watching the source directory for modifications
    watchPath(manifest\get("sourceDirectory"), modificationBind)

    -- If specified, also watch the package search paths
    if flags["-ws"] or flags["--watch-search"]
        resolverOptions = ResolverOptions\new(options\get("Resolver"))
        for path in *resolverOptions\get("searchPaths")
            watchPath(path, modificationBind)

    logInfo("Watching project directories for modification...")