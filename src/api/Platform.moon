import Object from "novacbn/novautils/utilities/Object"

-- Platform::Platform()
-- Represents a scripting platform that can be targeted by gmodproj
-- export
export Platform = Object\extend {
    -- Platform::isProduction -> boolean
    -- Represents if the current build is in production mode
    --
    isProduction: nil

    -- Platform::constructor(boolean isProduction)
    -- Constructor for Platform
    --
    constructor: (@isProduction) =>

    -- Platform::generatePackageHeader(string entryPoint) -> string
    -- Generates the header code of the built package
    --
    generatePackageHeader: (entryPoint) => ""

    -- Platform::generatePackageModule(string assetName, string assetChunk) -> string
    -- Transforms an asset and generates code understood by the platform's module system
    --
    generatePackageModule: (assetName, assetChunk) =>
        error("bad dispatch to 'generatePackageModule' (method not implemented)")

    -- Platform::generatePackageFooter() -> string
    -- Generates the footer code of the built package
    --
    generatePackageFooter: () => ""

    -- Platform::transformPackage(string packageContents) -> string
    -- Performs a final transformation on the built package
    --
    transformPackage: (packageContents) => packageContents
}