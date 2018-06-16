import unpack from _G

import pack from "novacbn/novautils/utilities"

import logInfo from "novacbn/gmodproj/lib/logging"
import ResolverOptions from "novacbn/gmodproj/schemas/ResolverOptions"
import readManifest from "novacbn/gmodproj/lib/utilities"
import watchPath from "novacbn/gmodproj/lib/utilities/fs"
bin     = dependency "novacbn/gmodproj/commands/bin"
build   = dependency "novacbn/gmodproj/commands/build"

-- ::makeBinding(table flags, string script, string ...) -> function
-- Make a bound function depending on if a script is specified
--
makeBinding = (flags, script, ...) ->
    if script then
        args = pack(...)
        return -> bin.executeCommand(flags, script, unpack(args))

    return -> build.executeCommand(flags, "development")

-- ::formatDescription(table flags) -> string
-- Formats the help description of the command
-- export
export formatDescription = (flags) ->
    return "watch [script]\t\t\t\tWatches the source directory for changes and rebuilds in development\n\t\t\t\t\t\t\tExecutes a script instead, if specified"

-- ::executeCommand(table flags, string script?) -> void
-- Watches the project's source directory, and search paths if specified, for rebuilding
-- export
export executeCommand = (flags, script, ...) ->
    options = readManifest()

    -- Retrieve the 'gmodproj bin [script] [...]' binding if a script is specified, otherwise use a 'gmodproj build development' binding
    modificationBind = makeBinding(flags, script, ...)

    -- Start watching the source directory for modifications
    watchPath(options\get("sourceDirectory"), modificationBind)

    -- If specified, also watch the package search paths
    if flags["-ws"] or flags["--watch-search"]
        resolverOptions = ResolverOptions\new(options\get("Resolver"))
        for path in *resolverOptions\get("searchPaths")
            watchPath(path, modificationBind)

    logInfo("Watching project directories for modification...")