#!/usr/bin/env bash
set -e

pacman -Sy --noconfirm curl git base-devel go

# Обычный пользователь всегда pc.
BUILD_USER="pc"

rm -rf /tmp/for_oneself
git clone --depth 1 https://github.com/VladMallory/for_oneself.git /tmp/for_oneself

chown -R "$BUILD_USER" /tmp/for_oneself

cd /tmp/for_oneself/arch/hyprland
sudo -u "$BUILD_USER" -H bash install.sh < /dev/tty
