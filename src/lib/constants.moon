import getenv from os
import arch, os from jit

import join from require "path"
import os_homedir from require "uv"

import isAffirmative from "novacbn/gmodproj/lib/utilities/string"

-- ::APPLICATION_CORE_VERSION -> table
-- Represents the current version of the application
-- export
export APPLICATION_CORE_VERSION = {0, 4, 3}

-- ::ENV_ALLOW_UNSAFE_SCRIPTING -> boolean
-- Represents a environment variable flag if gmodproj should allow unsafe scripting
-- export
export ENV_ALLOW_UNSAFE_SCRIPTING = isAffirmative(getenv("GMODPROJ_ALLOW_UNSAFE_SCRIPTING") or "y")

-- ::MAP_DEFAULT_PLUGINS -> table
-- Represents the default configuration of gmodproj plguins
-- export
export MAP_DEFAULT_PLUGINS = {
    "gmodproj-plugin-builtin": {}
}

-- ::SYSTEM_OS_ARCH -> string
-- Represents the architecture of the operating system
-- export
export SYSTEM_OS_ARCH = arch

-- ::SYSTEM_OS_TYPE -> string
-- Represents the type of operating system currently running
-- export
export SYSTEM_OS_TYPE = os

-- ::SYSTEM_UNIX_LIKE -> string
-- Represents if the operating system is unix-like in its environment
-- export
export SYSTEM_UNIX_LIKE = os == "Linux" or os == "OSX"

-- ::PROJECT_PATH -> table
-- Represents a map of paths for stored project data
-- export
export PROJECT_PATH = with {}
    -- PROJECT_PATH::home -> string
    -- Represents the home directory of the current project
    --
    .home = process.cwd()

    -- PROJECT_PATH::data -> string
    -- Represents the home directory of gmodproj's project data
    --
    .data = join(.home, ".gmodproj")

    -- PROJECT_PATH::bin -> string
    -- Represents the directory of utility scripts shipped with the project directory
    --
    .bin = join(.home, "bin")

    -- PROJECT_PATH::manifest -> string
    -- Represents the project's metadata manifest
    --
    .manifest = join(.home, ".gmodmanifest")

    -- PROJECT_PATH::packages -> string
    -- Represents the project's package manifest 
    --
    .packages = join(.home, ".gmodpackages")

    -- PROJECT_PATH::cache -> string
    -- Represents the directory of previously compiled modules in from the current project
    --
    .cache = join(.data, "cache")

    -- PROJECT_PATH::logs -> string
    -- Represents the directory of log files from actions previously taken for the current project
    --
    .logs = join(.data, "logs")

    -- PROJECT_PATH::plugins -> string
    -- Represents the directory of project installed plugin packages
    --
    .plugins = join(.data, "plugins")

-- ::USER_PATH -> table
-- Represents a map of paths for stored user data
-- export
export USER_PATH = with {}
    -- USER_PATH::home -> string
    -- Represents the home directory of gmodproj's user data
    --
    .home = join(os == "Windows" and getenv("APPDATA") or os_homedir(), ".gmodproj")

    -- USER_PATH::applications -> string
    -- Represents the globally installed command line applications
    --
    .applications = join(.home, "applications")

    -- USER_PATH::cache -> string
    -- Represents the directory of previously downloaded packages
    --
    .cache = join(.home, "cache")

    -- USER_PATH::plugins -> string
    -- Represents the directory of globally installed plugin packages
    --
    .plugins = join(.home, "plugins")