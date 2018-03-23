@echo off

:: Configuration for the build
if "%GMODPROJ_BUILD_MODE%"=="" (
    set BUILD_MODE="production"
) else (
    set BUILD_MODE="%GMODPROJ_BUILD_MODE%"
)

:: Dependent versions prerequisites
set LUVI_VERSION="2.7.6"
set LIT_VERSION="3.5.4"
set GMODPROJ_VERSION="0.2.0"

:: Download urls for prerequisites
set LUVI_URL="https://github.com/luvit/luvi/releases/download/v%LUVI_VERSION%/luvi-regular-Windows-amd64.exe"
set LIT_URL="http://lit.luvit.io/packages/luvit/lit/v%LIT_VERSION%.zip"
set GMODPROJ_URL="https://github.com/novacbn/gmodproj/releases/download/%GMODPROJ_VERSION%/gmodproj.x64.Windows.exe"

:: Download prerequisites
wget -O bin\luvi.exe "%LUVI_URL%" || goto error
wget -O bin\lit.zip "%LIT_URL%" || goto error
wget -O bin\gmodproj.exe "%GMODPROJ_URL%" || goto error

:: Make Luvit
cd bin
luvi.exe lit.zip -- make lit.zip lit.exe luvi.exe || goto error
lit.exe make lit://luvit/luvit luvit.exe luvi.exe || goto error
cd ..

:: Build gmodproj
bin\gmodproj.exe script buildDistributable $BUILD_MODE || goto error
del bin\gmodproj.exe
move /y dist\gmodproj.x64.Windows.exe bin
rename bin\gmodproj.x64.Windows.exe gmodproj.exe

:: Perform cleanup
del bin\lit.exe
del bin\lit.zip

:error
exit /b %errorlevel%