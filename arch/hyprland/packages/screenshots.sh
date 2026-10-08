#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Установка grimshot и зависимостей (grim, slurp, wl-clipboard, jq) ==="
sudo pacman -S --noconfirm --needed sway-contrib grim slurp wl-clipboard jq

log "Скриншоты готовы"
