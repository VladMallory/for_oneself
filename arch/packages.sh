#!/bin/bash

set -e

echo "=== Системные пакеты ==="
sudo pacman -S --needed --noconfirm \
    btop fastfetch ffmpeg rsync tree wget unzip firefox \
    thunar qalculate-gtk baobab qbittorrent

echo "=== AUR пакеты ==="
if ! command -v flclash &> /dev/null; then
    yay -S --needed --noconfirm flclash-bin localsend-bin
fi

echo "Пакеты установлены"
