#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$(dirname "$DIR")")"
source "$DIR/common.sh"

log "=== Установка FiraCode Nerd Font ==="

mkdir -p ~/.local/share/fonts

curl -L -o /tmp/FiraCode.zip \
  "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"

unzip -o /tmp/FiraCode.zip -d ~/.local/share/fonts/

rm -f /tmp/FiraCode.zip

fc-cache -fv ~/.local/share/fonts/

log "FiraCode Nerd Font установлен"
