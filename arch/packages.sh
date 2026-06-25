#!/bin/bash

set -e

echo "=== Системные пакеты ==="
sudo pacman -S --needed --noconfirm \
    btop fastfetch ffmpeg rsync tree wget unzip firefox \
    thunar qalculate-gtk baobab qbittorrent

echo "=== AUR пакеты ==="
yay -S --needed --noconfirm flclash-bin localsend-bin

echo "Пакеты установлены"
