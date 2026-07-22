#!/usr/bin/env bash
set -e

pacman -Sy --noconfirm curl git base-devel go

BUILD_USER="${SUDO_USER:-$(logname 2>/dev/null)}"

rm -rf /tmp/for_oneself
git clone --depth 1 https://github.com/VladMallory/for_oneself.git /tmp/for_oneself

if [ -n "$BUILD_USER" ]; then
    chown -R "$BUILD_USER" /tmp/for_oneself

    echo "$BUILD_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-temp-install
    chmod 440 /etc/sudoers.d/99-temp-install
    trap 'rm -f /etc/sudoers.d/99-temp-install' EXIT

    cd /tmp/for_oneself/arch
    sudo -u "$BUILD_USER" -H bash install.sh
else
    cd /tmp/for_oneself/arch
    bash install.sh
fi
