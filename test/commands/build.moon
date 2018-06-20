import chdir from require "uv"

import isDir from require "novacbn/gmodproj/lib/utilities/fs"

import BINARY_DIST from require "test/lib/constants"
import compareManifests from require "test/lib/utilities"

-- ::makeBuildTest(string template) -> void
-- Makes a build testing function for the specific project template type
--
makeBuildTest = (template) ->
    directory = "test"..template

    return () ->
        assert(isDir(directory), "expected '#{directory}' directory")

        chdir(directory)
        success, status, stdout = execFormat BINARY_DIST, "--no-cache", "--no-file", "build", "development"
        chdir("../")
        error(stdout) unless success

        compareManifests(directory, "development.#{template}.json")

        chdir(directory)
        success, status, stdout = execFormat BINARY_DIST, "--no-cache", "--no-file", "build", "production"
        chdir("../")
        error(stdout) unless success

        compareManifests(directory, "production.#{template}.json")

define "commands/build::AddonTemplate", makeBuildTest "addon"

define "commands/build::GamemodeTemplate", makeBuildTest "gamemode"