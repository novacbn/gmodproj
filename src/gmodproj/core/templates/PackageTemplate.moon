import Template from require "templates.Template"

TEXT_DUMMY_PACKAGE = [[
-- Code placed within this file can be imported from dependent projects
-- If this package was at 'github://author/mypackage1', it could be 
-- local mypackage1 = dependency("github://author/mypackage1/exports")
-- print(mypackage1.add(1, 1)) -- Prints '2' to console

function add(x, y)
    return x + y
end
]]

-- PackageTemplate::PackageTemplate()
-- Represents a project template for importable packages
PackageTemplate = Template
    -- PackageTemplate::PackageTemplate()
    -- Callback for generating the project template
    generate: () =>
        -- Create the project's manifest
        @createManifest("manifest.gmodproj", {
            Project: {
                entryPoints: {}
            },

            Packager: {
                buildDirectory:     "./build",
                minifyOutput:       true
            },

            Scripts: {}
        })

        -- Create the required directories
        @createDirectory("build")

        -- Create the dummy entry point files
        @createFile("exports.lua", TEXT_DUMMY_PACKAGE)

return :PackageTemplate