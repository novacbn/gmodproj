import pcall from _G
import resume, running, yield from coroutine

import readFileSync, mkdirSync from require "fs"

import decode from "novacbn/properties/exports"

import PROJECT_PATH from "novacbn/gmodproj/lib/constants"
import enableFileLogging, logError, logFatal from "novacbn/gmodproj/lib/logging"
import isDir, isFile from "novacbn/gmodproj/lib/utilities/fs"
import ProjectOptions from "novacbn/gmodproj/schemas/ProjectOptions"

-- ::configureEnvironment() -> void
-- Configures the project's directory environment
-- export
export configureEnvironment = () ->
    -- Create the directories needed and enable file logging
    mkdirSync(PROJECT_PATH.data) unless isDir(PROJECT_PATH.data)
    mkdirSync(PROJECT_PATH.cache) unless isDir(PROJECT_PATH.cache)
    mkdirSync(PROJECT_PATH.plugins) unless isDir(PROJECT_PATH.plugins)
    mkdirSync(PROJECT_PATH.logs) unless isDir(PROJECT_PATH.logs)

    enableFileLogging()

-- ::makeSync(function func) -> function
-- Makes a coroutine synchronus function out of a Luvit-style callback API
-- export
export makeSync = (func) ->
    return (...) ->
        thread = running()
        func(..., (...) -> resume(thread, ...))
        return yield()

-- ::readManifest() -> table
-- Reads the project's manifest file, fatally exits process on errors
-- export
export readManifest = () ->
    -- Read the project's manifest file if it exists
    logFatal(".gmodmanifest is a directory!") if isDir(PROJECT_PATH.manifest)
    options = {}
    options = decode(readFileSync(PROJECT_PATH.manifest), {propertiesEncoder: "moonscript"}) if isFile(PROJECT_PATH.manifest)

    -- Validate the project's manifest, alerting users to any validation errors
    success, err = pcall(ProjectOptions.new, ProjectOptions, options)
    unless success
        logError(err)
        logFatal("Failed to validate .gmodmanifest!")

    return err