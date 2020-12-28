#!/usr/bin/env bash
#
# Copyright (c) 2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Aria2-Pro-Core
# File name: aria2-install.sh
# Description: Install latest version Aria2
# System Required: Debian/Ubuntu or other
# Version: 1.5
#

set -e
[ $(uname) != Linux ] && {
    echo "This operating system is not supported."
    exit 1
}
[ $EUID != 0 ] && SUDO=sudo
$SUDO echo
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
INFO="[${Green_font_prefix}INFO${Font_color_suffix}]"
ERROR="[${Red_font_prefix}ERROR${Font_color_suffix}]"
ARCH=$(uname -m)
[ $(command -v dpkg) ] &&
    dpkgARCH=$(dpkg --print-architecture | awk -F- '{ print $NF }')

echo -e "${INFO} Check CPU architecture ..."
if [[ $ARCH == i*86 || $dpkgARCH == i*86 ]]; then
    ARCH="i386"
elif [[ $ARCH == "x86_64" || $dpkgARCH == "amd64" ]]; then
    ARCH="amd64"
elif [[ $ARCH == "aarch64" || $dpkgARCH == "arm64" ]]; then
    ARCH="arm64"
elif [[ $ARCH == "armv7l" || $dpkgARCH == "armhf" ]]; then
    ARCH="armhf"
else
    echo -e "${ERROR} This architecture is not supported."
    exit 1
fi

echo -e "${INFO} Get Aria2 download link ..."
TAG_NAME=$(curl -fsSL https://api.github.com/repos/P3TERX/Aria2-Pro-Core/releases/latest | grep -o '"tag_name": ".*"' | head -n 1 | cut -d'"' -f4)
[ -z $TAG_NAME ] && {
    echo -e "${ERROR} Unable to get Aria2 download link, network failure or API error."
    exit 1
}
ARIA2_VER=${TAG_NAME%_*}
BUILD_DATE=${TAG_NAME#*_}

echo -e "${INFO} Download Aria2 ${ARIA2_VER} (build ${BUILD_DATE} ${ARCH}) ..."
curl -L "https://github.com/P3TERX/Aria2-Pro-Core/releases/download/${TAG_NAME}/aria2-${ARIA2_VER}-static-linux-${ARCH}.tar.gz" | tar -xz
[ ! -s aria2c ] && {
    echo -e "${ERROR} Unable to download aria2, network failure or other error."
    exit 1
}

while [ $(command -v aria2c) ]; do
    echo -e "${INFO} Remove old version ..."
    $SUDO rm -rf $(command -v aria2c) || {
        echo -e "${ERROR} Unable to remove old version aria2 !"
        exit 0
    }
done

echo -e "${INFO} Installing Aria2 ${ARIA2_VER} (build ${BUILD_DATE} ${ARCH}) ..."
$SUDO mv aria2c /usr/local/bin &&
    echo -e "${INFO} Aria2 installed successfully !" ||
    {
        echo -e "${ERROR} Aria2 installation failed !"
        exit 1
    }

exit 0
