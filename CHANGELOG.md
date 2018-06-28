# gmodproj changelog

## 0.5.0
* Added `gmodproj add <...packages>`, `gmodproj install`, and `gmodproj remove <...packages>`
    * e.g. `gmodproj add github://novacbn/properties`
    * Format for Package URIs `scheme://path`
    * Accepted schemes
        * `git://path`
        * `github://username/package`
    * Accepts repository tags, e.g. `gmodproj add 0.2.0@github://novacbn/gmodproj-plugin-builtin`
        * By default, uses latest repository tag
        * Semantic versioning is not currently handled, WYSIWYG
* Refactored CLI to use [novacbn/command-ops](https://github.com/novacbn/command-ops)
* Updated CLI to use environmental variables for all flags
    * For `gmodproj build` flags such as `--no-cache` you can use `export GMODPROJ_NO_CACHE=y`
* Fixed CLI not accepting arguments that contain dashes
* Removed the following deprecated API and features
    * [0.4.3](#0.4.3)
        * `novacbn/gmodproj/lib/utilities/openssl`
    * [0.4.2](#0.4.2)
        * `-nf`, `--no-logs` - CLI Flag
    * [0.4.0](#0.4.0)
        * `novacbn/gmodproj/lib/datafile`

## 0.4.3
* Added [novacbn/luvit-extras](https://github.com/novacbn/luvit-extras) for extended `luvit` API features
* Added testing for these CLI commands
    * `gmodproj build`
    * `gmodproj new`
* Added the following bindings to `novacbn/gmodproj/lib/ScriptingEnvironment::ChunkEnvironment`
    * `novacbn/gmodproj/lib/constants::PROJECT_PATH`
* Updated the following bindings for `novacbn/gmodproj/lib/ScriptingEnvironment::ChunkEnvironment`
    * `_G::require(string name) -> any` - Now searches for scripts in the following order: project directory, gmodproj modules, Luvit modules
        * Supports `.moon` files in the project directory
* Updated bootstrap `gmodproj` to 0.4.3-indev
* Updated `novacbn/gmodproj/lib/constants::USER_PATH::home` to use `libuv` on non-Windows operating systems
* Updated CI to use test suite
* Deprecated the following APIs, to be removed in `5.0.0`
    * `novacbn/gmodproj/lib/utilities/fs`
        * `::collectFiles`, `::isDir`, `::isFile`, and `::watchPath` - Deprecated for `novacbn/gmodproj/luvit-extras/fs`
    * `novacbn/gmodproj/lib/utilities/openssl` - Fully deprecated for `novacbn/gmodproj/luvit-extras/crypto`

## 0.4.2
* Added `gmodproj clean` command, empties the `.gmodproj/cache` build cache directory of your project
    * Use `-ca` or `--clean-all` to enable all cleaning modes
    * Use `-cl` or `--clean-logs` to enable cleaning of the `.gmodproj/logs` directory of your project
    * Use `-nc` or `--no-cache` to disable cleaning of `.gmodproj/cache` directory
    * Use `-nl` or `--no-logs` to disable cleaning of `gmodproj/logs` directory of your project
* Added `gmodproj init` command, provides an interactive prompt for initializing an existing project to use `gmodproj`
* Added `gmodproj watch` command, naively watches your project's `sourceDirectory` (default `./src`) for changes and rebuilds in development mode
    * Use `-ws` or `--watch-search` to also watch search paths defined in `Resolver.searchPaths` (default `{'./packages'}`)
* Added `_G::define(string description, function callback) -> void` and `_G::test() -> number, string` to `novacbn/gmodproj/ScriptingEnvironment::ChunkEnvironment` for simple unit testing
    * In your utility scripts, define tests like
    ```lua
    define("mytest", function ()
        mypackage = require("dist/mypackage")
        assert(type(mypackage.add(1, 2)) == "number")
    end)
    ```

    * Then dispatch `_G::test()` at your script's footer, it will handle return status and message
    ```lua
    return test()
    ```
* Deprecated command line option `-nf`/`--no-file`, to be merged with `-nl`/`--no-logs` in `0.5.0`
* Updated [novacbn/gmodproj-plugin-builtin](https://github.com/novacbn/gmodproj-plugin-builtin) to `0.2.1`, fixes [#14](https://github.com/novacbn/gmodproj/issues/14)
* Updated cli to be more consistent
* Updated `gmodproj bin`
    * Operating system scripts no longer exit the `gmodproj` directly, on successful execution

## 0.4.1
* (EXPERIMENTAL) Added macOS builds added via TravisCI
    * Note, I don't have a macOS device to test on. Therefore will not be able to really help with macOS specific issues
* Added `_G::SYSTEM_UNIX_LIKE -> boolean`, `_G::assert(any ...) -> any ...`, and `_G::error(string err, number level) -> void` to `novacbn/gmodproj/ScriptingEnvironment::ChunkEnvironment`
* Updated `gmodproj.lua` builds, now platform specific in distribution
* Updated CI scripts for `0.4.0`
* Updated formatting for `gmodproj bin` executions
    * `-1` status code is reserved for Lua and MoonScript files with syntax errors
* Updated `novacbn/gmodproj/commands/bin` to use `_G::loadfile` and `moonscript/base::loadfile` for better handling of scripts
* Fixed project creation via `gmodproj new`

## 0.4.0
* Added the `is_key_pair` for keypair validation using `novacbn/gmodproj/api/Schema`
    * **definition**
    ```lua
    {
        is_key_pair: {keyType/tableOfTypes, valueType/tableOfTypes}
    }
    ```

    * **sample**
    ```lua
    myKey = {
        is_key_pair = {"string", {"boolean", "number"}}
    }
    ```

    * **valid sample data**
    ```lua
    myKey = {
        validStringNumber   = 3,
        validStringBoolean  = false,
    }
    ```
* Added missing error string for `MINIMUM_ITEMS` Schema validation code
* Added fatal log on missing build directory
* Added `writeProperites` to `novacbn/gmodproj/api/Template::Template`
    * Removed `writeDataFile` as a result, update `Template` classes to adhere to the new `.gmodmanifest` format
* Fixed all version information containing `0.0.3` -> `0.3.0`
* Deprecated `novacbn/gmodproj/lib/datafile` in favor of [novacbn/properties](https://github.com/novacbn/properties)
    * Removal in `0.5.0`
* Updated project `.gmodmanifest` to no longer take scripts and renamed `gmodproj script <scriptName>` to `gmodproj bin <scriptName>`
    * Now executes scripts found within `${PROJECTHOME}/bin` without their file extension.
    * Supported script types:
        * `.lua`
        * `.moon`
        * `.sh` - Linux only
        * `.bat` - Windows only
* Updated `manifest.gmodproj` and `packages.gmodproj` to `.gmodmanifest` and `.gmodpackages`
    * Both are now using [novacbn/properties](https://github.com/novacbn/properties) for parsing
        * See `gmodproj`'s [.gmodmanifest](https://github.com/novacbn/gmodproj/blob/master/.gmodmanifest) as an example
    * The following properties were renamed for simplification:
        `projectName` -> `name`
        `projectAuthor` -> `author`
        `projectRepository` -> `repository`
        `projectVersion` -> `version`
        `entryPoints` -> `projectBuilds`
* Updated various Schemas have been updated
    * `ProjectOptions.projectBuilds` - Only accepts `string` keys and `string` or `table` values keypairs
    * `ProjectOptions.Plugins` - Only accepts `string` keys and `table` values keypairs
* Updated various module paths for organization/consistency
    * `novacbn/gmodproj/lib/digests` -> `novacbn/gmodproj/lib/utilities/openssl`
    * `novacbn/gmodproj/lib/fsx` -> `novacbn/gmodproj/lib/utilities/fs`
    * `novacbn/gmodproj/lib/utilities/assertx` -> `novacbn/gmodproj/lib/utilities/assert`
    * `novacbn/gmodproj/lib/utilities/stringx` -> `novacbn/gmodproj/lib/utilities/string`
* Upgraded `novacbn/gmodproj-builtin-plugin` to `0.2.0`
    * Supports `.lprop` and `.mprop` file formats via [novacbn/properties](https://github.com/novacbn/properties)
* Refactored `Application.moon` to `main.moon` and `commands/<command>.moon` for easier reasoning about of current and future commands

## 0.3.0
* Added third-party/dependencies references to `README.md`
* Added `Project.projectRepository` and `Project.projectVersion` metadata fields in `manifest.gmodproj`
    * Will be used in the future for package installations
* Added support for targetting different scripting platforms, targets set in `Packager.targetPlaform`: `lua, garrysmod`
    * Default target is `garrysmod`, if standard Lua project, update accordingly
* Added support including assets automatically into your build via `Packager.includedAssets`, glob patterns supported
* Added support for excluding assets automatically from your build via `Packager.excludedAssets`, glob patterns supported
* Added options flags that affect various commands:
    * `-q, --quiet`, silences all command line output
    * `-nf, --no-file`, silences all file logging in `${PROJECTHOME}/.gmodproj/logs`
    * `-nc, --no-cache`, disables caching built project files to `${PROJECTHOME}/.gmodproj/cache`
* Added support for extending `gmodproj` via plugins
    * See [gmodproj-plugin-builtin](https://github.com/novacbn/gmodproj-plugin-builtin) as a sample plugin, which is also shipped with `gmodproj`
    * Add your plugins in one of these directories for `gmodproj` to pick them up:
        * Per-project: `${PROJECTHOME}/.gmodproj/plugins`
        * All projects:
            * Linux: `~/.gmodproj/plugins`
            * Windows: `%APPDATA%\.gmodproj\plugins`
        * Shipping with `gmodproj`: `deps/plugins`
* Added 'module' variable to packaged assets environments, supporting the following:
    * `module.name`     - Name of the asset's import name for the package
    * `module.globals`  - Global variables shared by all assets in the specific package
* Updated functionality of `gmodproj`, spun-off default asset and platform support into seperate bundled plugin [gmodproj-plugin-builtin](https://github.com/novacbn/gmodproj-plugin-builtin)
* Updated `gmodproj build` command:
    * `gmodproj build [development]` now formats the project's assets as escapsed Lua strings, using the targetted platform's native runtime code loading to load and perserve asset names and stack traces
        * This results in larger builds, and MoonScript assets are NOT compiled to keep same code lines as source
    * `gmodproj build production` now supports minified builds, set minification level via `Project.Plugins["gmodproj-plugin-builtin"].minificationLevel`
* Updated bundling functionality. Project files in the specified `Project.sourceDirectory` field will automatically be prefixed with `${PROJECTAUTHOR}/${PROJECTNAME}` support proper namespacing
* Factored out most utility functionality into [novautils](https://github.com/novacbn/novautils)
    * Using `novacbn/novautils/Object` for OOP instead of MoonScript's `class` keyword. Allowing Lua, and other languages, to use `gmodproj`'s OOP functionality more readily
    * All of `novautils 0.2.0` is included as a supplemental std library. Access in plugins via `gmodproj.require('novacbn/novautils/...')`
* Fixed regression of `gmodproj build` not supporting dashes in import names