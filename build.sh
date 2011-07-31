#!/bin/sh

cd `dirname $0` || exit 1

[ "x$BUILD_REPO" = "x" ] && BUILD_REPO=git://android.git.crystax.net/cosp/android/build.git
[ "x$BUILD_DIR" = "x" ] && BUILD_DIR=./build
cwd=`pwd`
if [ ! -d $BUILD_DIR ]; then
  cd `dirname $BUILD_DIR` || exit 1
  git clone $BUILD_REPO `basename $BUILD_DIR` || exit 1
else
  cd $BUILD_DIR || exit 1
  git pull || exit 1
fi
cd $cwd || exit 1
. $BUILD_DIR/build-common.sh || exit 1

export PREFIX ARCH

CC=$TOOLCHAIN_PREFIX-gcc
AR=$TOOLCHAIN_PREFIX-ar
RANLIB=$TOOLCHAIN_PREFIX-ranlib
export CC AR RANLIB

make libbz2 install-libbz2 || exit 1

