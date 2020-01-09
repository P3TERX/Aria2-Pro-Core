#!/usr/bin/env bash
#=================================================
# https://github.com/P3TERX/aria2-builder
# File name: aria2-install.sh
# Description: Install latest version Aria2
# System Required: Debian/Ubuntu or other
# Version: 1.0
# Lisence: GPLv3
# Author: P3TERX
# Blog: https://p3terx.com (chinese)
#=================================================
set -e
[ $(uname) != Linux ] && {
    echo -e "This operating system is not supported."
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
[[ ${ARCH} != "x86_64" && ${ARCH} != "aarch64" ]] && {
    echo -e "${ERROR} This architecture is not supported."
    exit 1
}
echo -e "${INFO} Check the version of Aria2 ..."
ARIA2_VER=$(curl -fsSL https://api.github.com/repos/P3TERX/aria2-builder/releases | grep -o '"tag_name": ".*"' | head -n 1 | sed 's/"//g;s/v//g' | sed 's/tag_name: //g')
[ -z $ARIA2_VER ] && {
    echo -e "${ERROR} Unable to check the version, network failure or API error."
    exit 1
}
[ $(command -v aria2) ] && {
    [[ $(aria2 -v | grep $ARIA2_VER) ]] && {
        echo -e "${INFO} The latest version is installed."
        exit 0
    } || {
        echo -e "${INFO} Uninstall the old version ..."
        $SUDO rm -rf $(command -v aria2)
    }
}
aria2_name="aria2-${ARIA2_VER}-static-linux-${ARCH}"
echo -e "${INFO} Download Aria2 ..."
curl -fsSLO "https://github.com/P3TERX/aria2-builder/releases/download/${ARIA2_VER}/${aria2_name}.tar.gz" || {
    echo -e "${ERROR} Unable to download aria2, network failure or other error."
    exit 1
}
echo -e "${INFO} Installation Aria2 ..."
tar zxf ${aria2_name}.tar.gz
$SUDO mv aria2c /usr/local/bin && echo -e "${INFO} Aria2 successful installation !" || {
    echo -e "${ERROR} Aria2 installation failed !"
    exit 1
}
rm -rf ${aria2_name}*
