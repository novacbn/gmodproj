import getenv from os
import arch, os from jit

import join from require "path"

-- ::APPLICATION_CORE_VERSION -> table
-- Represents the current version of the application
export APPLICATION_CORE_VERSION = {0, 1, 0}

-- ::ENV_ALLOW_UNSAFE_SCRIPTING -> boolean
-- Represents a environment variable flag if gmodproj should allow unsafe scripting
export ENV_ALLOW_UNSAFE_SCRIPTING = switch getenv("GMODPROJ_ALLOW_UNSAFE_SCRIPTING")
                                        when "no" then false
                                        else true
--when "no" or "n" or "0" or "f" or "false" then false

-- ::PATH_DIRECTORY_PROJECT -> string
-- Represents the project directory
export PATH_DIRECTORY_PROJECT = process.cwd()

-- ::PATH_DIRECTORY_DATA -> string
-- Represents the project's build data folder
export PATH_DIRECTORY_DATA = join(PATH_DIRECTORY_PROJECT, "/.gmodproj")

-- ::PATH_DIRECTORY_CACHE -> string
-- Represents the project's build cache
export PATH_DIRECTORY_CACHE = join(PATH_DIRECTORY_DATA, "/cache")

-- ::PATH_DIRECTORY_LOGS -> string
-- Represents the project's file logs
export PATH_DIRECTORY_LOGS = join(PATH_DIRECTORY_DATA, "/logs")

-- ::PATH_FILE_MANIFEST -> string
-- Represent's the project's metadata manifest
export PATH_FILE_MANIFEST = join(PATH_DIRECTORY_PROJECT, "/manifest.gmodproj")

-- ::PATH_FILE_PACKAGES -> string
-- Represents the project's dependency graph
export PATH_FILE_PACKAGES = join(PATH_DIRECTORY_PROJECT, "/packages.gmodproj")

-- ::PATTERN_METADATA_NAME -> pattern
-- Represents a metadata value that should be dashes and lowercase alphanumeric only
export PATTERN_METADATA_NAME = "^%l[%l%d%-]*$"

-- ::SYSTEM_OS_ARCH -> string
-- Represents the architecture of the operating system
export SYSTEM_OS_ARCH = arch

-- ::SYSTEM_OS_TYPE -> string
-- Represents the type of operating system currently running
export SYSTEM_OS_TYPE = os