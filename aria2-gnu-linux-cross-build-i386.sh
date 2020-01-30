#!/usr/bin/env bash
#===========================================================
# https://github.com/P3TERX/aria2-builder
# File name: aria2-gnu-linux-cross-build-i386.sh
# Description: Cross build Aria2 i386 version
# System Required: Debian & Ubuntu & Fedora & Arch Linux
# Lisence: GPLv3
# Version: 1.1
# Author: P3TERX
# Blog: https://p3terx.com (chinese)
#===========================================================
set -e
[ $EUID != 0 ] && SUDO=sudo
$SUDO echo

## DEPENDENCES ##
ZLIB='http://sourceforge.net/projects/libpng/files/zlib/1.2.11/zlib-1.2.11.tar.gz'
EXPAT='https://github.com/libexpat/libexpat/releases/download/R_2_2_9/expat-2.2.9.tar.bz2'
C_ARES='http://c-ares.haxx.se/download/c-ares-1.15.0.tar.gz'
OPENSSL='http://www.openssl.org/source/openssl-1.1.1d.tar.gz'
SQLITE3='https://sqlite.org/2019/sqlite-autoconf-3300100.tar.gz'
LIBSSH2='https://www.libssh2.org/download/libssh2-1.9.0.tar.gz'

## CONFIG ##
ARCH="i386"
HOST="i686-linux-gnu"
OPENSSL_ARCH="linux-elf"
BUILD_DIR="/tmp"
OUTPUT_DIR="$HOME/output"
PREFIX="$BUILD_DIR/aria2-cross-build-libs-$ARCH"
ARIA2_PREFIX=$HOME/aria2-local
export CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export LD_LIBRARY_PATH="$PREFIX/lib"
export CC="$HOST-gcc"
export CXX="$HOST-g++"
export STRIP="$HOST-strip"
export RANLIB="$HOST-ranlib"
export AR="$HOST-ar"
export LD="$HOST-ld"

DEBIAN_INSTALL(){
    $SUDO apt-get update
    $SUDO apt-get -y install build-essential git curl ca-certificates \
        libxml2-dev libcppunit-dev autoconf automake autotools-dev autopoint libtool pkg-config \
        gcc-$HOST g++-$HOST
}

FEDORA_INSTALL(){
    $SUDO dnf install -y make kernel-devel git curl ca-certificates bzip2 xz findutils \
        libxml2-devel cppunit autoconf automake gettext-devel libtool pkg-config dpkg \
        gcc-$HOST gcc-c++-$HOST
}

ARCH_INSTALL(){
    $SUDO pacman -Syu --noconfirm base-devel git dpkg $HOST-gcc
}

TOOLCHAIN(){
    if [ -x "$(command -v apt-get)" ]; then
        DEBIAN_INSTALL
    elif [ -x "$(command -v dnf)" ]; then
        FEDORA_INSTALL
    elif [ -x "$(command -v pacman)" ]; then
        ARCH_INSTALL
    else
        echo -e "This operating system is not supported !"
        exit 1
    fi
}

ZLIB_BUILD(){
    mkdir -p $BUILD_DIR/zlib && cd $BUILD_DIR/zlib
    curl -Ls -o - "$ZLIB" | \
        tar zxvf - --strip-components=1
    ./configure \
        --prefix=$PREFIX \
        --static
    make install
}

EXPAT_BUILD(){
    mkdir -p $BUILD_DIR/expat && cd $BUILD_DIR/expat
    curl -Ls -o - "$EXPAT" | \
        tar jxvf - --strip-components=1
    ./configure \
        --host=$HOST \
        --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
        --prefix=$PREFIX \
        --enable-static=yes \
        --enable-shared=no
    make install
}

C_ARES_BUILD(){
    mkdir -p $BUILD_DIR/c-ares && cd $BUILD_DIR/c-ares
    curl -Ls -o - "$C_ARES" | \
        tar zxvf - --strip-components=1
    ./configure \
        --host=$HOST \
        --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
        --prefix=$PREFIX \
        --enable-static --disable-shared
    make install
}

OPENSSL_BUILD(){
    mkdir -p $BUILD_DIR/openssl && cd $BUILD_DIR/openssl
    curl -Ls -o - "$OPENSSL" | \
        tar zxvf - --strip-components=1
    ./Configure \
        --prefix=$PREFIX \
        --openssldir=ssl \
        $OPENSSL_ARCH \
        no-asm \
        shared
    make install
}

SQLITE3_BUILD(){
    mkdir -p $BUILD_DIR/sqlite3 && cd $BUILD_DIR/sqlite3
    curl -Ls -o - "$SQLITE3" | \
        tar zxvf - --strip-components=1
    ./configure \
        --host=$HOST \
        --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
        --prefix=$PREFIX \
        --enable-static \
        --enable-shared
    make install
}

LIBSSH2_BUILD(){
    mkdir -p $BUILD_DIR/libssh2 && cd $BUILD_DIR/libssh2
    curl -Ls -o - "$LIBSSH2" | \
        tar zxvf - --strip-components=1
    rm -rf $PREFIX/lib/pkgconfig/libssh2.pc
    ./configure \
        --host=$HOST \
        --prefix=$PREFIX \
        --enable-static \
        --disable-shared \
        CPPFLAGS="-I$PREFIX/include" \
        LDFLAGS="-L$PREFIX/lib"
    make install
}

ARIA2_SOURCE(){
    [ -e $BUILD_DIR/aria2 ] && {
        cd $BUILD_DIR/aria2
        git reset --hard origin || git reset --hard
        git pull
    } || {
        git clone https://github.com/aria2/aria2 $BUILD_DIR/aria2
        cd $BUILD_DIR/aria2
    }
    autoreconf -i
    $ARIA2_VER=master
}

ARIA2_RELEASE(){
    [ -e "$ARIA2_VER" ] || \
        ARIA2_VER=$(curl -fsSL https://api.github.com/repos/aria2/aria2/releases | grep -o '"tag_name": ".*"' | head -n 1 | sed 's/"//g;s/v//g' | sed 's/tag_name: //g')
    mkdir -p $BUILD_DIR/aria2 && cd $BUILD_DIR/aria2
    ARIA2_VER=${ARIA2_VER#*-}
    curl -Ls -o - "https://github.com/aria2/aria2/releases/download/release-${ARIA2_VER}/aria2-${ARIA2_VER}.tar.xz" | \
        tar Jxvf - --strip-components=1
}

ARIA2_BUILD(){
    ARIA2_RELEASE || ARIA2_SOURCE
    echo "修改最大连接数TEXT_MAX_CONNECTION_PER_SERVER"
    sed -i 's/1", 1, 16/128", 1, -1/' src/OptionHandlerFactory.cc
    echo "修改PREF_MIN_SPLIT_SIZE, TEXT_MIN_SPLIT_SIZE"
    sed -i 's/"20M", 1_m, 1_g/"4K", 1_k, 1_g/' src/OptionHandlerFactory.cc
    echo "修改TEXT_CONNECT_TIMEOUT"
    sed -i 's/TEXT_CONNECT_TIMEOUT, "60", 1, 600/TEXT_CONNECT_TIMEOUT, "30", 1, 600/' src/OptionHandlerFactory.cc
    echo "修改TEXT_PIECE_LENGTH"
    sed -i 's/TEXT_PIECE_LENGTH, "1M", 1_m/TEXT_PIECE_LENGTH, "4k", 1_k/' src/OptionHandlerFactory.cc
    echo "修改TEXT_RETRY_WAIT"
    sed -i 's/TEXT_RETRY_WAIT, "0", 0, 600/TEXT_RETRY_WAIT, "2", 0, 600/' src/OptionHandlerFactory.cc
    echo "修改PREF_SPLIT, TEXT_SPLIT"
    sed -i 's/PREF_SPLIT, TEXT_SPLIT, "5"/PREF_SPLIT, TEXT_SPLIT, "8"/' src/OptionHandlerFactory.cc
    ./configure \
        --host=$HOST \
        --prefix=${ARIA2_PREFIX:-'/usr'} \
        --without-libxml2 \
        --without-libgcrypt \
        --with-openssl \
        --without-libnettle \
        --without-gnutls \
        --without-libgmp \
        --with-libssh2 \
        --with-sqlite3 \
        --with-libexpat \
        --with-libz \
        --with-ca-bundle='/etc/ssl/certs/ca-certificates.crt' \
        ARIA2_STATIC=yes \
        --enable-shared=no
    make
}

ARIA2_PACKAGE(){
    cd $BUILD_DIR/aria2/src
    $HOST-strip aria2c
    mkdir -p $OUTPUT_DIR
    tar Jcvf $OUTPUT_DIR/aria2-$ARIA2_VER-static-linux-$ARCH.tar.xz aria2c
    tar zcvf $OUTPUT_DIR/aria2-$ARIA2_VER-static-linux-$ARCH.tar.gz aria2c
}

ARIA2_INSTALL(){
    cd $BUILD_DIR/aria2
    make install-strip
}

CLEANUP_SRC(){
    cd $BUILD_DIR
    rm -rf \
        zlib \
        expat \
        c-ares \
        openssl \
        sqlite3 \
        libssh2 \
        aria2
}

CLEANUP_LIB(){
    rm -rf $PREFIX
}

CLEANUP_ALL(){
    CLEANUP_SRC
    CLEANUP_LIB
}

## BUILD ##
TOOLCHAIN
ZLIB_BUILD
EXPAT_BUILD
C_ARES_BUILD
OPENSSL_BUILD
SQLITE3_BUILD
LIBSSH2_BUILD
ARIA2_BUILD
ARIA2_PACKAGE
CLEANUP_ALL

echo "finished!"
