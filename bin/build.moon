import hashSHA256 from dependency "novacbn/gmodproj/lib/utilities/openssl"

-- Configure the environment for building
buildMode       = ({...})[1] or "production"
isProduction    = buildMode\lower() == "production"
buildMode       = isProduction and "production" or "development"
mkdir "./dist" unless isDir "./dist"

-- Configure the build process depending on the Operating System
local BINARY_LUVI, BINARY_LUVIT, BINARY_UPX, BINARY_GMODPROJ, BINARY_DIST
if SYSTEM_OS_TYPE == "Linux"
    BINARY_LUVI     = "./bin/luvi"
    BINARY_LUVIT    = "./bin/luvit"
    BINARY_UPX      = "./bin/upx"
    BINARY_GMODPROJ = "./bin/gmodproj"

    if isProduction then BINARY_DIST    = "./dist/gmodproj.#{SYSTEM_OS_ARCH}.#{SYSTEM_OS_TYPE}"
    else BINARY_DIST                    = "./dist/gmodproj-dev.#{SYSTEM_OS_ARCH}.#{SYSTEM_OS_TYPE}"

if SYSTEM_OS_TYPE == "Windows"
    BINARY_LUVI     = "bin\\luvi.exe"
    BINARY_LUVIT    = "bin\\luvit.exe"
    BINARY_UPX      = "bin\\upx.exe"
    BINARY_GMODPROJ = "bin\\gmodproj.exe"

    if isProduction then BINARY_DIST    = "dist\\gmodproj.#{SYSTEM_OS_ARCH}.#{SYSTEM_OS_TYPE}.exe"
    else BINARY_DIST                    = "dist\\gmodproj-dev.#{SYSTEM_OS_ARCH}.#{SYSTEM_OS_TYPE}.exe"

-- Produce a project build of gmodproj
success, status, stdout = execFormat BINARY_GMODPROJ, "build", buildMode
return 1, "Project build failed: (#{status})\n#{stdout}" unless success

-- Create a distributable executable with the local Luvit binaries
success, status, stdout = execFormat BINARY_LUVI, "./build", "-m", "main.lua", "-o", BINARY_DIST, BINARY_LUVIT
return 2, "Binary creation failed: (#{status})\n#{stdout}" unless success

-- Compress the binary if possible
if isProduction and exists(BINARY_UPX) and isFile(BINARY_UPX)
    success, status, stdout = execFormat BINARY_UPX, BINARY_GMODPROJ
    return 3, "Binary compression failed: (#{status})\n#{stdout}" unless success

-- Clean up files for distribution
write "./dist/gmodproj.lua", read("./build/gmodproj.lua")
remove "./build/gmodproj.lua"

-- If running Linux, add executable flag to build
if SYSTEM_OS_TYPE == "Linux"
    execFormat "chmod", "+x", BINARY_DIST

-- If a production build, hash the build output
if isProduction
    write "./dist/gmodproj.lua.sha256", hashSHA256(read("./dist/gmodproj.lua"))
    write BINARY_DIST..".sha256", hashSHA256(read(BINARY_DIST))

-- Log success!
return 0, "Succesfully built gmodproj in #{buildMode} mode!"