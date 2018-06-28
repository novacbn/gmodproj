import match from string
import insert from table

import mkdirSync, readdirSync, renameSync, rmdirSync, unlinkSync from require "fs"
import resolve from require "path"
import isdirSync from "novacbn/luvit-extras/fs"

import logInfo, logFatal from "novacbn/gmodproj/lib/logging"
import tmpdir from "novacbn/gmodproj/lib/utilities/fs"

PACKAGES = {
    "git": dependency("novacbn/gmodproj/packages/GitPackage").GitPackage
}

-- ::PATTERN_URI_PACKAGE -> string
-- Represents a Lua pattern to validate and extract from a Package URI
--
PATTERN_URI_PACKAGE = "^([%w]+)://([%w%./%-]+)$"

-- ::PATTERN_URI_TAG -> string
-- Represents a Lua pattern to validate and extract from a Package URI with a tag
--
PATTERN_URI_TAG = "([%w%.]+)@([%w]+)://([%w%./%-]+)$"

-- ::contains(table tbl, any search) -> boolean
-- Returns if the table has the search value
--
contains = (tbl, search) ->
    for value in *tbl
        return true if value == search

    return false

-- ::removeDirectory(string directory) -> void
-- Recursively empties and removes the given directory
--
removeDirectory = (directory) ->
    for name in *readdirSync(directory)
        name = resolve(directory, name)
        if isdirSync(name) then removeDirectory(name)
        else unlinkSync(name)

    rmdirSync(directory)

-- ::validateTag(Package package, string url, string tag) -> string
-- Validates that the remote package contains the tag
--
validateTag = (package, url, tag) ->
    tags    = package\tags(url)
    logFatal("Package '#{scheme}://#{path}' has no available tags") unless #tags > 0

    tag = tag or tags[#tags]
    logFatal("Package '#{scheme}://#{path}' does not contain tag '#{tag}'") unless contains(tags, tag)
    return tag

-- ::validateURI(string uri) -> Package, string
-- Validates the URI and returns the canonical URL
--
validateURI = (uri) ->
    tag, scheme, path   = match(uri, PATTERN_URI_TAG)
    tag, scheme, path   = nil, match(uri, PATTERN_URI_PACKAGE) unless scheme and path
    logFatal("Package URI '#{uri}' is malformed") unless scheme and path

    package = PACKAGES[scheme]
    logFatal("Unknown Package Scheme '#{scheme}'") unless package
    return package, package\formatCanonicalURL(scheme, path)

-- ::TEXT_COMMAND_DESCRIPTION -> string
-- Represents the description of the command
-- export
export TEXT_COMMAND_DESCRIPTION = "Installs a package for the project"

-- ::TEXT_COMMAND_SYNTAX -> string
-- Represents the syntax of the command
-- export
export TEXT_COMMAND_SYNTAX = "<...packages>"

-- ::TEXT_COMMAND_EXAMPLES -> string
-- Represents the examples of the command
-- export
export TEXT_COMMAND_EXAMPLES = {
    "github://novacbn/luvit-extras"
    "github://novacbn/properties"
}

-- ::executeCommand(Options options, string ...) -> void
-- Adds a dependencies to the current working project
-- export
export executeCommand = (options, ...) ->
    packages = {}

    uris = {...}
    for uri in *uris
        package, url, tag   = validateURI(uri)
        tag                 = validateTag(package, url, tag)

        tempDirectory = tmpdir()
        package\fetch(url, tempDirectory, tag)

        package                         = package\new(tempDirectory)
        projectOptions                  = package\getProjectOptions()
        author, name, sourceDirectory   = projectOptions\get("author"), projectOptions\get("name"), package\getSourceDirectory()

        mkdirSync("packages") unless isdirSync("packages")
        mkdirSync("packages/#{author}") unless isdirSync("packages/#{author}")
        removeDirectory("packages/#{author}/#{name}") if isdirSync("packages/#{author}/#{name}")

        renameSync(sourceDirectory, "packages/#{author}/#{name}")
        removeDirectory(tempDirectory)

        logInfo("Fetched package '#{uri}'")

    logInfo("Installed #{#uris} packages")