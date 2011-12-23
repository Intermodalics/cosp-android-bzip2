#!/bin/sh

cd `dirname $0` || exit 1

. build/cosp-android-common.sh || exit 1

export PREFIX ARCH

CC=$TOOLCHAIN_PREFIX-gcc
AR=$TOOLCHAIN_PREFIX-ar
RANLIB=$TOOLCHAIN_PREFIX-ranlib
export CC AR RANLIB

OUTDIR=$OUTDIR/bzip2
export OUTDIR

make -j$BUILD_NUM_JOBS libbz2 install-libbz2 || exit 1

