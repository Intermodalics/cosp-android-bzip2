#!/bin/sh

cd `dirname $0` || exit 1

. ../build/build-common.sh || exit 1

export PREFIX ARCH

CC=$TOOLCHAIN_ABI-gcc
AR=$TOOLCHAIN_ABI-ar
RANLIB=$TOOLCHAIN_ABI-ranlib
export CC AR RANLIB

make libbz2 install-libbz2 || exit 1

