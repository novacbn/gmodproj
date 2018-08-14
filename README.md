# gmodproj
[![Build status](https://ci.appveyor.com/api/projects/status/8p7qgdoxvt7smodx?svg=true)](https://ci.appveyor.com/project/novacbn/gmodproj) [![Build Status](https://travis-ci.org/novacbn/gmodproj.svg)](https://travis-ci.org/novacbn/gmodproj)

**[Releases](https://github.com/novacbn/gmodproj/releases) &bullet;**
A simple to get started, but easy to hack, project manager for Garry's Mod

## Hiatus
Project is currently on hiatus for the near future.

## Current Status
`gmodproj` is currently in `pre-alpha`, and is recommended only for experimentation and testing purposes only! So keep this in mind:
* Documentation is sorely lacking, that's **next priority**!
* `.gmodmanifest` and `.gmodpackages` files are both not stablized as-of yet. In the future these may break.
* Remote package installation is not supported as-of yet, packages must be manually installed to your project's `packages` folder _(or other specified search paths)_.
* The API for extending `gmodproj` with installable packages is also not stablized, so any current extensions may also break.

With that said however, `gmodproj` does support these features:
* Creating new projects with `gmodproj new`, allowing you to quickly bootstrap various types of Garry's Mod projects without boilerplate or configuration.
* Projects can be built with `gmodproj build [development/production]` into self-contained distributable `.lua` files. **_(`gmodproj` is self-hosted as an example)_**
    * Builds are also incremental, no rebuilding the entire project slowing down the process.
    * Automatically build when you edit a project file with `gmodproj watch [script]`
* A per-project `packages` folder that allows your to seperate your external dependencies with your internal ones.
    * You can also specifiy more search paths for packages in your project's manifest!
* Run `.lua` and `.moon` files from your project's `bin` directory in `gmodproj`'s scripting environment via `gmodproj bin <script> <...>` for task automation.
    * Can also run operating system `.sh` _(Linux/macOS)_ and `.bat` _(Windows)_ files aswell.
* Easily extendable with plugins, see [gmodproj-plugin-builtin](httsp://github.com/novacbn/gmodproj-plugin-builtin) as a sample plugin. Which also powers the built-in functionality of `gmodproj`
    * Just put built plugins in your project's `.gmodproj/plugins` directory or for all your projects, `%APPDATA%\.gmodproj\plugins` _(Windows)_ or `~/.gmodproj/plugins` _(Linux)_
    * Then enable them in your `manifest.gmodproj`, see `gmodproj`'s own [manifest.gmodproj](https://github.com/novacbn/gmodproj/blob/master/manifest.gmodproj) as an example.

## Getting Started
First you need to grab the latest release from the [Releases](https://github.com/novacbn/gmodproj/releases) and place the binary somewhere within PATH environmental variable is set up to see.

#### Setting up an Addon project
1. In a terminal goto the parent directory of where you would like to make your project reside, e.g. `/home/USERNAME/Workspace`
2. Create a new project with the `addon` template using, `gmodproj new addon my-name my-gamemode`.
3. Goto your newly created `my-project` directory and start programming, using the `src/client.lua` and `src/server.lua`.
4. Once finished, navigate to your project's directory with your terminal, type `gmodproj build`. Which will build your project to `addons/lua/autorun/client/my-project.client.lua` and `addons/lua/autorun/server/my-project.server.lua`
5. Copy the `addons` directory into your Garry's Mod Client or SRCDS Server's `garrysmod` directory, and then start up your game.
6. You're done and can continue program and debug using this routine.

#### Setting up a Gamemode project
1. In a terminal goto the parent directory of where you would like to make your project reside, e.g. `/home/USERNAME/Workspace`
2. Create a new project with the `gamemode` template using, `gmodproj new gamemode my-name my-gamemode`.
3. Goto your newly created `my-project` directory and start programming, using the `src/client.lua` and `src/server.lua`.
4. Once finished, navigate to your project's directory with your terminal, type `gmodproj build`. Which will build your project to `gamemodes/my-project/gamemode/my-project.client.lua` and `gamemodes/myproject/gamemode/my-project.server.lua`
5. Copy the `gamemodes` directory into your Garry's Mod Client or SRCDS Server's `garrysmod` directory, and then start up your game.
6. You're done and can continue program and debug using this routine.

## CLI Options
```shell
novacbn@lunasol$ gmodproj help
Garry's Mod Project Manager :: 0.4.1 Pre-alpha
Syntax:         gmodproj [flags] [command]

Examples:       gmodproj bin prebuild
                gmodproj build production
                gmodproj new addon novacbn my-addon

Flags:
        -ca, --clean-all                        Enables cleaning of all generated project files
        -cl, --clean-logs                       Enables cleaning of project log files
        -nc, --no-cache                         Disables caching and cleaning of built project files
        -nf, --no-file                          Disables logging to files
        -nl, --no-logs                          Disables cleaning of project log files
        -q, --quiet                             Disables output to console
        -ws, --watch-search                     Enables watching package search paths specified in project manifest

Commands:
        bin <script>                            Executes a utility script located in your project's 'bin' directory
        build [mode]                            Builds your project into distributable Lua files
                                                        (DEFAULT) 'development', 'production'
        clean                                   Cleans the build cache of the project
        init                                    Initializes an already existing project to work with gmodproj
        new <template> <author> <name>          Creates a new directory for your project via a template
                                                        'addon', 'gamemode', 'package'
        version                                 Displays the version text of application
        watch [script]                          Watches the source directory for changes and rebuilds in development
                                                        Executes a script instead, if specified
```

## Building From Source
#### Prerequitises
* `curl` - Requires `curl` to download files, if building from source on Windows.
* `wget` - Requires `wget` to download files, if building from source on macOS/Linux.
* `luvit` - Requires [luvit](https://luvit.io/) binaries to be present in the project's `/bin` directory.
    * Automatically retrieved and built if using `./bin/bootstrap.sh` _(or `bin\bootstrap.bat` if on Windows)_
* `gmodproj` - Requires a pre-built version of `gmodproj` to be present in the project's `/bin` directory.
* **_(OPTIONAL)_** `upx` - If using `gmodproj bin build production` to build, it will automatically detect if [upx](https://upx.github.io/) is in the `/bin` directory and use it.

#### Building
* Navigate to your copy of `gmodproj`'s source code directory in a terminal.
* In your terminal, type `./bin/bootstrap.sh` _(or `bin\bootstrap.bat` if on Windows)_
    * It will automatically download and build the prerequitises files, then compile `gmodproj`
* Once complete, a new `gmodproj` _(or `gmodproj.exe` if on Windows)_ will be located in your `/bin` directory.

## Frequently Asked Questions (FAQ)
#### Can you provide an installer for `gmodproj` instead of me mucking with things myself?
It's eventually planned to provide some installer scripts to help with this, although current installation method is pretty straight-forward.

#### How do I exports values for my other scripts in my build to use?
Any value that isn't localized will be exported, e.g.:
```lua
-- src/script1.lua
function myFunc1()
    print("hello")
end

local function myFunc2()
    print("goodbye")
end
```

```lua
-- src/script2.lua
local script1 = import("my-name/my-project/script1")

script1.myFunc1() -- Will print 'hello'
script2.myFunc2() -- Will error at runtime
```

#### Why can't I export my Lua globals for external scripts to use?
`gmodproj` monkey patches your project's scripts so any normal exports to globals is instead added to your script's exports. This is for to the virtual import system that comes with your project's build.

To export globals, assign to the `_G` variable any values your want, e.g.:
```lua
local function myFunc()
    --- ...code goes here...
end

_G.mynamespace = {}
_G.mynamespace.myFunc = myFunc
```

#### What types of assets can I import?
By default, `gmodproj` supports the following scripting languages:
* `.lua`
* `.moon` - MoonScript scripting language, transpile to valid Lua code on build.

By default, `gmodproj` also supports the following data markups:
* `.datl`           - Lua Data File, the data format used by `gmodproj` based on `MoonScript` formatting, compiled to a Lua table at build time. **(DEPRECATED)**
* `.json`           - JavaScript Object Notation, a common data transfer format, compiled to a Lua table at build time.
* `.toml`           - Tom's Obvious Minimal Language, a simple configuration format, compiled to a Lua table at build time.
* `.lprop`          - Lua-based human-readable properties format, using standard Lua table syntax.
* `.mprop`          - MoonScript-based human-readable properties format, using standard MoonScript table syntax.

#### Do MoonScript files handle imports differently than Lua files?
Ever so slightly, yes. As seen in the `gmodproj` codebase, MoonScript allows for slightly streamlined importing:
```moonscript
-- script3.moon
import myFunc1 from "script1"
myFunc1()
```

Which is special-case transpiled into:
```lua
local myFunc1 = dependency("my-name/my-project/script1").myFunc1
myFunc1()
```

Due to `import` being a keyword in MoonScript, you can use the alias `dependency` just like in Lua code:
```moonscript
script1 = dependency "my-name/my-project/script1"
myFunc1()
```

#### How do I distribute my source code?
Same as any other source code, just make sure to upload `.gmodmanifest` so people can build your project, and include your `packages` folder aswell.

#### Can I use this for non-Garry's Mod projects?
By default, `gmodproj` targets Garry's Mod during the build process. To target standard Lua, add `targetPlatform: 'lua'` to your `.gmodmanifest`.

#### Will gmodproj support globally installed dependencies?
While you can add search pathes to your `.gmodmanifest` to facilitate this functionality, `gmodproj` will **never** support global dependencies out of the box.

#### Will support (globally) installed dependencies as CLI tools?
Yes to both, this is planned for the future.

## Dependencies/Third-Party

* [creationix/luvit](https://luvit.io/)
* [davidm/lua-glob-pattern](https://github.com/davidm/lua-glob-pattern)
* [fperrad/lua-LIVR](https://github.com/fperrad/lua-LIVR)
* [leafo/moonscript](https://github.com/leafo/moonscript)
* [novacbn/novautils](https://github.com/novacbn/novautils)
* [novacbn/properties](https://github.com/novacbn/properties)
* [pkulchenko/serpent](https://github.com/pkulchenko/serpent)
* [rxi/json](https://github.com/rxi/json)
* [starwing/gettime.lua](https://gist.github.com/starwing/1757443a1bd295653c39)
