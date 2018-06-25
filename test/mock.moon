import chdir from require "novacbn/luvit-extras/process"

import BINARY_DIST, TMP_DIR from require "test/lib/constants"
import generateManifest, writeData from require "test/lib/utilities"

-- ::generateTemplateManifest(string template) -> table
-- Helper function for generating template manifests
--
generateTemplateManifest = (template) ->
    success, status, stdout = execFormat BINARY_DIST, "new", template, "testauthor", "test"..template
    error(stdout) unless success

    return generateManifest("test"..template)

-- ::generateBuildManifest(string directory) -> table, table
-- Helper function for generating build manifests
--
generateBuildManifest = (directory) ->
    chdir(directory)

    success, status, stdout = execFormat BINARY_DIST, "--no-cache", "--no-file", "build", "development"
    error(stdout) unless success

    developmentManifest = generateManifest("./")

    success, status, stdout = execFormat BINARY_DIST, "--no-cache", "--no-file", "build", "production"
    error(stdout) unless success

    chdir("../")

    return developmentManifest, generateManifest(directory)

chdir(TMP_DIR)

-- Mock manifests for each project template type
templateAddon       = generateTemplateManifest "addon"
templateGamemode    = generateTemplateManifest "gamemode"
templatePackage     = generateTemplateManifest "package"

-- Mock development and production manifests of each project template type
developmentAddon, productionAddon       = generateBuildManifest "testaddon"
developmentGamemode, productionGamemode = generateBuildManifest "testgamemode"

-- Cache the manifests for later testing
writeData "development.addon.json", developmentAddon
writeData "development.gamemode.json", developmentGamemode
writeData "production.addon.json", productionAddon
writeData "production.gamemode.json", productionGamemode
writeData "template.addon.json", templateAddon
writeData "template.gamemode.json", templateGamemode
writeData "template.package.json", templatePackage