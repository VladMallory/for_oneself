#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Установка wl-clipboard и grimshot ==="
sudo pacman -S --noconfirm --needed sway-contrib

log "Скриншоты готовы"
