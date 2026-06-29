#!/usr/bin/env bash
set -e

if ! command -v curl &>/dev/null; then
    pacman -Sy --noconfirm curl
fi
git clone https://github.com/VladMallory/for_oneself.git /tmp/for_oneself
cd /tmp/for_oneself/arch
bash gen-config.sh
archinstall --config archinstall-config.json --creds archinstall-creds.json
