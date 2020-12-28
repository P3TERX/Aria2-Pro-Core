#!/usr/bin/env bash
#
# Copyright (c) 2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Aria2-Pro-Core
# File name: aria2-gnu-linux-cross-build-armhf.sh
# Description: Aria2 armhf platform cross build
# System Required: Ubuntu 14.04/16.04
# Version: 1.6
#

set -e
[ $EUID != 0 ] && SUDO=sudo
$SUDO echo
SCRIPT_DIR=$(dirname $(readlink -f $0))

## CONFIG ##
ARCH="armhf"
HOST="arm-linux-gnueabihf"
OPENSSL_ARCH="linux-generic32"
BUILD_DIR="/tmp"
ARIA2_CODE_DIR="$BUILD_DIR/aria2"
OUTPUT_DIR="$HOME/output"
PREFIX="$BUILD_DIR/aria2-cross-build-libs-$ARCH"
ARIA2_PREFIX="$HOME/aria2-local"
export CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export LD_LIBRARY_PATH="$PREFIX/lib"
export CC="$HOST-gcc"
export CXX="$HOST-g++"
export STRIP="$HOST-strip"
export RANLIB="$HOST-ranlib"
export AR="$HOST-ar"
export LD="$HOST-ld"

## DEPENDENCES ##
source $SCRIPT_DIR/dependences

## TOOLCHAIN ##
source $SCRIPT_DIR/snippet/cross-toolchain

TOOLCHAIN() {
    if [ -x "$(command -v apt-get)" ]; then
        DEBIAN_INSTALL
    else
        echo -e "This operating system is not supported !"
        exit 1
    fi
}

## BUILD ##
source $SCRIPT_DIR/snippet/cross-build

## ARIA2 COEDE ##
source $SCRIPT_DIR/snippet/aria2-code

## ARIA2 BIN ##
source $SCRIPT_DIR/snippet/aria2-bin

## CLEAN ##
source $SCRIPT_DIR/snippet/clean

## BUILD PROCESS ##
TOOLCHAIN
ZLIB_BUILD
EXPAT_BUILD
C_ARES_BUILD
OPENSSL_BUILD
SQLITE3_BUILD
LIBSSH2_BUILD
JEMALLOC_BUILD
ARIA2_BUILD
#ARIA2_BIN
ARIA2_PACKAGE
#ARIA2_INSTALL
CLEANUP_ALL

echo "finished!"
