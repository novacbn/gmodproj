#!/usr/bin/env sh
set -e

# Configuration for the build
if [ -n $GMODPROJ_BUILD_MODE ]; then
    BUILD_MODE=$GMODPROJ_BUILD_MODE
else
    BUILD_MODE="production"
fi

# Dependent versions prerequisites
LUVI_VERSION="2.7.6"
LIT_VERSION="3.5.4"
GMODPROJ_VERSION="0.2.0"

# Download urls for prerequisites
LUVI_URL="https://github.com/luvit/luvi/releases/download/v$LUVI_VERSION/luvi-regular-Linux_x86_64"
LIT_URL="http://lit.luvit.io/packages/luvit/lit/v$LIT_VERSION.zip"
GMODPROJ_URL="https://github.com/novacbn/gmodproj/releases/download/$GMODPROJ_VERSION/gmodproj.x64.Linux"

# Download prerequisites
echo "Downloading prerequisite files..."
wget -nv -O ./bin/luvi $LUVI_URL
wget -nv -O ./bin/lit.zip $LIT_URL
wget -nv -O ./bin/gmodproj $GMODPROJ_URL

# Make luvit
echo "\n\nMaking luvit"
cd ./bin
chmod +x ./luvi
./luvi lit.zip -- make lit.zip lit luvi
./lit make lit://luvit/luvit luvit luvi
cd ../

# Make gmodproj
echo "\n\nMaking gmodproj"
chmod +x ./bin/gmodproj
./bin/gmodproj script buildDistributable $BUILD_MODE
mv -f ./dist/gmodproj.x64.Linux ./bin/gmodproj
chmod +x ./bin/gmodproj

# Perform cleanup
echo "\n\nPerforming cleanup..."
rm ./bin/lit
rm ./bin/lit.zip

# Log completion to user
echo "\n\nBuild complete, use './bin/gmodproj.exe buildDistributable [buildMode]' from now on!"