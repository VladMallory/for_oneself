#!/usr/bin/env bash

echo "удаление старого конфига"
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim ~/.local/state/nvim

echo "скачивание astronvim"
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
rm -rf ~/.config/nvim/.git

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "перенос настроек"
mkdir -p ~/.config/nvim/lua

cp -r "$SCRIPT_DIR/v4/lua/"* ~/.config/nvim/lua/
