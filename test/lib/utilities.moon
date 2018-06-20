import tmpname from require "os"
import readFileSync, mkdirSync, unlinkSync from require "fs"
import join, normalizeSeparators from require "path"

import collectFiles from require "novacbn/gmodproj/lib/utilities/fs"
import hashSHA1 from require "novacbn/gmodproj/lib/utilities/openssl"

-- ::compareManifests(string directory, string target) -> void
-- Compares the stored manifest data with the newly generated manifest
-- export
local generateManifest, readData
compareManifests = (directory, target) ->
    sourceManifest  = generateManifest(directory)
    targetManifest  = {normalizeSeparators(name), checksum for name, checksum in pairs(readData(target))}

    for name, checksum in pairs(targetManifest)
        error("file '#{name}' is missing from output") unless sourceManifest[name]
        error("invalid SHA-1 checksum of '#{name}'") unless sourceManifest[name] == checksum

-- ::generateManifest(string directory) -> table
-- Generates a manifest of SHA-1 checksums for each file in the directory recursively
-- export
generateManifest = (directory) ->
    return {name, hashSHA1(readFileSync(join(directory, name))) for name in *collectFiles(directory)}

-- ::readData(string name) -> table
-- Loads a JSON data file from the test directory of the project
-- export
readData = (name) ->
    return readJSON(join(PROJECT_PATH.home, "test", "data", name))

-- ::tmpdir() -> string
-- Create and returns a directory in the system's temporary directory
-- export
tmpdir = () ->
    name = tmpname()
    unlinkSync(name)
    mkdirSync(name)
    return name

-- ::writeData(string name, table data) ->
-- Writes a JSON data file to the test directory of the project
-- export
writeData = (name, data) ->
    writeJSON(join(PROJECT_PATH.home, "test", "data", name), data)

return :compareManifests, :generateManifest, :readData, :tmpdir, :writeData