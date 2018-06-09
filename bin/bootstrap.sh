#!/usr/bin/env sh
set -e

# Use environment variable for build mode if set
if [ -n $GMODPROJ_BUILD_MODE ]; then
    BUILD_MODE=$GMODPROJ_BUILD_MODE
else
    BUILD_MODE="production"
fi

# Dependent versions prerequisites
LIT_VERSION="3.5.4"
LUVI_VERSION="2.7.6"

# Download urls for prerequisites
LIT_URL="http://lit.luvit.io/packages/luvit/lit/v$LIT_VERSION.zip"
if [ "$(uname)" = "Darwin" ]; then
    LUVI_URL="https://github.com/luvit/luvi/releases/download/v$LUVI_VERSION/luvi-regular-Darwin_x86_64"

else
    LUVI_URL="https://github.com/luvit/luvi/releases/download/v$LUVI_VERSION/luvi-regular-Linux_x86_64"
fi

# Download prerequisites
echo "Downloading prerequisite files..."
wget -nv -O ./bin/luvi $LUVI_URL
wget -nv -O ./bin/lit.zip $LIT_URL

# Make luvit
echo "\n\nMaking luvit"
cd ./bin
chmod +x ./luvi
./luvi lit.zip -- make lit.zip lit luvi
./lit make lit://luvit/luvit luvit luvi
cd ../

# Make gmodproj
echo "\n\nMaking gmodproj"
./bin/luvi ./build -m main.lua -o ./bin/gmodproj ./bin/luvit
chmod +x ./bin/gmodproj

# Perform cleanup
echo "\n\nPerforming cleanup..."
rm ./bin/lit
rm ./bin/lit.zip

# Log completion to user
echo "\n\nBuild complete, use './bin/gmodproj bin build [buildMode]' from now on!"