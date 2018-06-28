import readFileSync from require "fs"
import resolve from require "path"
import isfileSync from "novacbn/luvit-extras/fs"
import Object from "novacbn/novautils/utilities/Object"
import decode from "novacbn/properties/exports"

import PackagerOptions from "novacbn/gmodproj/schemas/PackagerOptions"
import ProjectOptions from "novacbn/gmodproj/schemas/ProjectOptions"
import ResolverOptions from "novacbn/gmodproj/schemas/ResolverOptions"

-- Package::Package()
-- Represents a generic package source that gmodproj can pull packages from
-- export
export Package = Object\extend {
    -- Package::baseDirectory -> string
    -- Represents the base directory of the package
    --
    baseDirectory: nil

    -- Package::packagerOptions -> PackagerOptions
    -- Represents the packager options of the package
    --
    packagerOptions: nil

    -- Package::projectOptions -> ProjectOptions
    -- Represents the project options of the package
    --
    projectOptions: nil

    -- Package::resolverOptions -> ResolverOptions
    -- Represents the resolver options of the package
    --
    resolverOptions: nil

    -- Package::constructor(string directory) -> void
    -- Constructor for Package
    --
    constructor: (directory) =>
        @baseDirectory = directory

    -- Package::isAvailable() -> boolean
    -- Returns if the prerequisites for this source are available on the system
    -- static
    isAvailable: () => error("bad dispatch to 'isAvailable' (unimplemented method)")

    -- Package::fetch(string scheme, string path, string directory, string tag?) -> void
    -- Fetches the package from the source into the specified directory
    -- static
    fetch: (scheme, path, directory, tag) => error("bad dispatch to 'fetch' (unimplemented method)")

    -- Package::formatCanonicalURL(string uri) -> string
    -- Validates the URI and returns the canonical representation of the package source
    -- static
    formatCanonicalURL: (uri) => error("bad dispatch to 'formatCanonicalURL' (unimplemented method)")

    -- Package::getPackagerOptions() -> PackagerOptions
    -- Reads the package's project manifest and validates and returns the Packager options
    --
    getPackagerOptions: () =>
        unless @packagerOptions
            options             = @getProjectOptions()
            @packagerOptions    = PackagerOptions\new(options\get("Packager"))

        return @packagerOptions

    -- Package::getProjectOptions() -> ProjectOptions
    -- Reads and validates the package's project manifest
    --
    getProjectOptions: () =>
        unless @projectOptions
            file = resolve(@baseDirectory, ".gmodmanifest")
            error("bad dispatch to 'getProjectOptions' (expected project manifest)") unless isfileSync(file)

            options         = decode(readFileSync(file), {propertiesEncoder: "moonscript"})
            @projectOptions = ProjectOptions\new(options)

        return @projectOptions

    -- Package::getResolverOptions() -> ResolverOptions
    -- Reads the package's project manifest and validates and returns the Resolver options
    --
    getResolverOptions: () =>
        unless @resolverOptions
            options             = @getProjectOptions()
            @resolverOptions    = ResolverOptions\new(options\get("Resolver"))

        return @resolverOptions

    -- Package::getBuildDirectory() -> string
    -- Reads the package's manifest and returns the absolute build directory
    --
    getBuildDirectory: () =>
        options = @getProjectOptions()
        return resolve(@baseDirectory, options\get("buildDirectory"))

    -- Package::getSourceDirectory() -> string
    -- Reads the package's manifest and returns the absolute source directory
    --
    getSourceDirectory: () =>
        options = @getProjectOptions()
        return resolve(@baseDirectory, options\get("sourceDirectory"))

    -- Package::getSearchPaths() -> string
    -- Reads the package's manifest and returns the absolute search paths
    --
    getSearchPaths: () =>
        options = @getResolverOptions()
        return [resolve(directory) for directory in *options\get("searchPaths")]
}