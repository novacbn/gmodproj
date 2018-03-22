# gmodproj
[[Latest](releases/latest) &bullet; [Releases](releases)] A simple to get started, but easy to hack, project manager for Garry's Mod

---

## Current Status
`gmodproj` is currently in `pre-alpha`, and is recommended only for experimental and testing purposes only! So keep this in mind:
* Documentation is sorely lacking, that's **next priority**!
* `manifest.gmodproj` and `lock.gmodproj` files are both not standardized as-of yet. In the future these may break.
* `gmodproj` does not support a watch mode yet, so `gmodproj build` must be ran manually.
* Remote package installation is not supported as-of yet, packages must be manually installed to your project's `packages` folder _(or other specified search paths)_.
* The API for extending `gmodproj` with installable packages is also not standardized, so any current extensions may also break.

With that said however, `gmodproj` does support these features:
* Creating new projects with `gmodproj new`, allowing you to quickly bootstrap various types of Garry's Mod projects without boilerplate or configuration.
* Projects can be built with `gmodproj build [development/production]` into self-contained distributable `.lua` files. **_(`gmodproj` is self-hosted as an example)_**
    * Builds are also incremental, no rebuilding the entire project slowing down the process.
* A per-package `packages` folder that allows your to seperate your external dependencies with your internal ones.
    * You can also specifiy more search paths for packages in your project's manifest!
* Run `MoonScript` code as defined in your project's `manifest.gmodproj` for task automation.
    * You can also define your scripts as strings instead of function bodies, they will be ran in your Operating System's shell scripting interpreter.

## Getting Started
First you need to grab the latest release from the [Releases Page](releases/latest) and place the binary somewhere within PATH environmental variable is set up to see.

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
Garry's Mod Project Manager :: 0.2.0 Pre-alpha

Syntax:     gmodproj [command]

Examples:   gmodproj build production
            gmodproj new addon novacbn my-addon
            gmodproj run prebuild

Commands:
    help                            Shows this help prompt
    new <template> <author> <name>  Creates a new directory for your project's with a template layout
                                        'addon', 'gamemode', 'package'

    build [mode]                    Builds your project into distributable Lua files
                                        (DEFAULT) 'development', 'production'
    script <script>                 Runs a specified script from your project manifest's 'Scripts'
```

## Building From Source
#### Prerequitises
* `luvit` - Requires [luvit](https://luvit.io/) binaries to be present in the project's `/bin` directory.
* `gmodproj` - Requires a pre-built version of `gmodproj`, will eventually get around to adding a non-self-hosted method.
* **_(OPTIONAL)_** `upx` - If using `gmodproj script buildDistributable [production]` to build, it will automatically detect if [upx](https://upx.github.io/) is in the `/bin` directory and use it.

#### Building
* After setting up the prerequitises, download this repository's source code into a directory.
* Open a terminal located in the new directory and type `gmodproj script buildDistributable`.
* When finished, a newly minted `gmodproj` _(or `gmodproj.exe` if on Windows)_ will be located in the `/bin` directory of the source code.

## Frequently Asked Questions (FAQ)
#### Can you provide an installer for `gmodproj` instead of me mucking with things myself?
It's eventually planned to provide some installer scripts to help with this, although current installation method is pretty straight-forward.

#### How do I exports values for my other scripts in my build to use?
Any value that isn't localized will be exported, e.g.:
```lua
-- script1.lua
function myFunc1()
    print("hello")
end

local function myFunc2()
    print("goodbye")
end
```

```lua
-- script2.lua
local script1 = import("script1")

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
* `.moon` - MoonScript files, transpiled to Lua as build time.

By default, `gmodproj` also supports the following data markups:
* `.datl` - Lua Data File, the data format used by `gmodproj` based on `MoonScript` formatting, compiled to a Lua table at build time.
* `.json` - JavaScript Object Notation, a common data transfer format, compiled to a Lua table at build time.
* `.toml` - Tom's Obvious Minimal Language, a simple configuration format, compiled to a Lua table at build time.

#### Do MoonScript files handle imports differently than Lua files?
Ever so slightly, yes. As seen in the `gmodproj` codebase, MoonScript allows for slightly streamlined importing:
```moonscript
-- script3.moon
import myFunc1 from "script1"
myFunc1()
```

Which is special-case transpiled into:
```lua
local myFunc1 = dependency("script1").myFunc1
myFunc1()
```

Due to `import` being a keyword in MoonScript, you can use the alias `dependency` just like in Lua code:
```moonscript
script1 = dependency "script1"
myFunc1()
```

#### How do I distribute my source code?
Same as any other source code, just make sure to upload `manifest.gmodproj` so people can build your project, and include your `packages` folder aswell.

#### Can I use this for non-Garry's Mod projects?
By default, `gmodproj` has no Garry's Mod specific features other than the built-in project templates used for the `gmodproj new` command. Otherwise you should be good to go.

#### Will gmodproj support globally installed dependencies?
While you can add search pathes to your `manifest.gmodproj` to facilitate this functionality, `gmodproj` will **never** support global dependencies out of the box.

#### Will support (globally) installed dependencies as CLI tools?
Yes to both, this is planned for the future.