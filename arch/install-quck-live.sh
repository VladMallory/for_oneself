#!/usr/bin/env bash
set -e

pacman -Sy --noconfirm curl git
git clone https://github.com/VladMallory/for_oneself.git /tmp/for_oneself
cd /tmp/for_oneself/arch
bash gen-config.sh
archinstall --config archinstall-config.json --creds archinstall-creds.json
