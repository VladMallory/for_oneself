#!/usr/bin/env bash
set -e

pacman -Sy --noconfirm curl git reflector

# --- лучшие зеркала перед установкой ---
echo "=== Настройка зеркал pacman (reflector) ==="
reflector --country Russia --latest 10 --protocol https --sort rate \
    --save /etc/pacman.d/mirrorlist || echo "WARN: reflector не смог обновить зеркала"
pacman -Syy --noconfirm || true

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
