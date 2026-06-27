#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Установка wl-clipboard и grimshot ==="
yay -S --noconfirm --needed wl-clipboard grimshot

log "Скриншоты готовы"
