import BINARY_DIST from require "test/lib/constants"
import compareManifests from require "test/lib/utilities"

define "commands/new::AddonTemplate", ->
    success, status, stdout = execFormat BINARY_DIST, "new", "addon", "testauthor", "testaddon"
    assert(success, stdout)

    compareManifests "testaddon", "template.addon.json"

define "commands/new::GamemodeTemplate", ->
    success, status, stdout = execFormat BINARY_DIST, "new", "gamemode", "testauthor", "testgamemode"
    assert(success, stdout)

    compareManifests "testgamemode", "template.gamemode.json"

define "commands/new::PackageTemplate", ->
    success, status, stdout = execFormat BINARY_DIST, "new", "package", "testauthor", "testpackage"
    assert(success, stdout)

    compareManifests "testpackage", "template.package.json"