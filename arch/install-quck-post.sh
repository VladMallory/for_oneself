#!/usr/bin/env bash
set -e

pacman -Sy --noconfirm curl git

git clone --depth 1 https://github.com/VladMallory/for_oneself.git /tmp/for_oneself
cd /tmp/for_oneself/arch
bash install.sh
