#!/usr/bin/env bash
set -e

if ! command -v curl &>/dev/null; then
    sudo pacman -Sy --noconfirm curl
fi
git clone --depth 1 https://github.com/VladMallory/for_oneself.git /tmp/for_oneself
cd /tmp/for_oneself/arch
bash install.sh
