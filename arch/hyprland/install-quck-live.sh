#!/usr/bin/env bash
set -e

pacman -Sy --noconfirm curl git
git clone https://github.com/VladMallory/for_oneself.git /tmp/for_oneself
cd /tmp/for_oneself/arch/hyprland

# --- размер swap ---
DEFAULT_SWAP_GB=20
if [ -t 0 ]; then
    read -r -p "Сколько ГБ swap нужно? [$DEFAULT_SWAP_GB]: " SWAP_GB || true
fi
SWAP_GB="${SWAP_GB:-$DEFAULT_SWAP_GB}"
export SWAP_GB

bash gen-config.sh
archinstall --config archinstall-config.json --creds archinstall-creds.json
