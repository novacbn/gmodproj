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
GMODPROJ_VERSION_SRC="master"

# Download urls for prerequisites
LUVI_URL="https://github.com/luvit/luvi/releases/download/v$LUVI_VERSION/luvi-regular-Linux_x86_64"
LIT_URL="http://lit.luvit.io/packages/luvit/lit/v$LIT_VERSION.zip"
GMODPROJ_SRC_URL="https://github.com/novacbn/gmodproj/archive/$GMODPROJ_VERSION_SRC.tar.gz"
GMODPROJ_URL="https://github.com/novacbn/gmodproj/releases/download/$GMODPROJ_VERSION/gmodproj.x64.Linux"

# Download prerequisites
wget -O ./luvi $LUVI_URL
wget -O ./lit.zip $LIT_URL
wget -O ./gmodproj $GMODPROJ_URL
wget -O ./gmodproj.tar.gz $GMODPROJ_SRC_URL

# Make Luvit
chmod +x ./luvi
./luvi lit.zip -- make lit.zip lit luvi
./lit make lit://luvit/luvit luvit luvi

# Configure the environment for building
tar -xf ./gmodproj.tar.gz
cd ./gmodproj-$GMODPROJ_VERSION_SRC

mkdir ./bin
mv ../luvi ./bin
mv ../luvit ./bin
mv ../gmodproj ./bin
chmod +x ./bin/gmodproj

# Build gmodproj
echo $BUILD_MODE
./bin/gmodproj script buildDistributable $BUILD_MODE
mv -f ./dist/gmodproj.x64.Linux ./bin/gmodproj
chmod +x ./bin/gmodproj
cd ../
mv ./gmodproj-$GMODPROJ_VERSION_SRC ./gmodproj

# Perform cleanup
rm ./lit
rm ./lit.zip
rm ./gmodproj.tar.gz