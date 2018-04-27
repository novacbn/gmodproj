# gmodproj changelog

## 0.0.3
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
* Fixed regression of `gmodproj build` not supporting