import createHash from dependency "novacbn/gmodproj/lib/utilities/openssl"

-- Configure the environment for building
buildMode       = ({...})[1] or "production"
isProduction    = buildMode\lower() == "production"
buildMode       = isProduction and "production" or "development"
mkdir "./dist" unless isDir "./dist"

-- Configure build process depending on build mode
BUILD_TAG                       = "-dev.#{SYSTEM_OS_ARCH}.#{SYSTEM_OS_TYPE}"
if isProduction then BUILD_TAG  = ".#{SYSTEM_OS_ARCH}.#{SYSTEM_OS_TYPE}"

-- Configure the build process depending on the Operating System
local BINARY_LUVI, BINARY_LUVIT, BINARY_UPX, BINARY_GMODPROJ, BINARY_DIST, BUILD_DIST
if SYSTEM_UNIX_LIKE
    BINARY_LUVI     = "./bin/luvi"
    BINARY_LUVIT    = "./bin/luvit"
    BINARY_UPX      = "./bin/upx"
    BINARY_GMODPROJ = "./bin/gmodproj"

    BUILD_DIST  = "./dist/gmodproj#{BUILD_TAG}.lua"
    BINARY_DIST = "./dist/gmodproj#{BUILD_TAG}"

elseif SYSTEM_OS_TYPE == "Windows"
    BINARY_LUVI     = "bin\\luvi.exe"
    BINARY_LUVIT    = "bin\\luvit.exe"
    BINARY_UPX      = "bin\\upx.exe"
    BINARY_GMODPROJ = "bin\\gmodproj.exe"

    BUILD_DIST  = "dist\\gmodproj#{BUILD_TAG}.lua"
    BINARY_DIST = "dist\\gmodproj#{BUILD_TAG}.exe"
else return 1, "Unsupported build platform '#{SYSTEM_OS_ARCH} #{SYSTEM_OS_TYPE}'"

-- Produce a project build of gmodproj
success, status, stdout = execFormat BINARY_GMODPROJ, "build", buildMode
return 2, "Project build failed: (#{status})\n#{stdout}" unless success

-- Create a distributable executable with the local Luvit binaries
success, status, stdout = execFormat BINARY_LUVI, "./build", "-m", "main.lua", "-o", BINARY_DIST, BINARY_LUVIT
return 3, "Binary creation failed: (#{status})\n#{stdout}" unless success

-- Compress the binary if possible
if isProduction and exists(BINARY_UPX) and isFile(BINARY_UPX)
    success, status, stdout = execFormat BINARY_UPX, BINARY_GMODPROJ
    return 4, "Binary compression failed: (#{status})\n#{stdout}" unless success

-- Clean up files for distribution
write BUILD_DIST, read("./build/gmodproj.lua")
remove "./build/gmodproj.lua"

-- If running on a Unix-like system, add executable flag to build
if SYSTEM_UNIX_LIKE
    execFormat "chmod", "+x", BINARY_DIST

-- If a production build, hash the build output
if isProduction
    write BUILD_DIST..".sha256", hashSHA256(read(BUILD_DIST))
    write BINARY_DIST..".sha256", hashSHA256(read(BINARY_DIST))

-- Log success!
return 0, "Succesfully built gmodproj in '#{buildMode}' mode!"