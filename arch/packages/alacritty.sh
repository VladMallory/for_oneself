#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$(dirname "$DIR")")"
source "$DIR/common.sh"

log "=== Установка Alacritty ==="
sudo pacman -S --needed --noconfirm alacritty

log "=== Копирование конфига Alacritty ==="
mkdir -p ~/.config/alacritty
cp "$REPO/alacrity/alacrity.toml" ~/.config/alacritty/alacritty.toml

log "Alacritty установлен и настроен"
