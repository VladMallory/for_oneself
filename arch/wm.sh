#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$DIR")"

echo "=== Установка Sway и Waybar ==="
sudo pacman -S --needed --noconfirm \
    sway waybar rofi \
    mako grim slurp \
    pipewire wireplumber pavucontrol brightnessctl \
    networkmanager network-manager-applet blueman xorg-xwayland \
    polkit-kde-agent \
    ttf-jetbrains-mono-nerd

echo "=== Копирование конфига Sway ==="
mkdir -p ~/.config/sway
cp "$REPO/wm/sway/config" ~/.config/sway/config

echo "=== Копирование конфига Waybar ==="
mkdir -p ~/.config/waybar
cp "$REPO/wm/waybar/config" ~/.config/waybar/config
cp "$REPO/wm/waybar/style.css" ~/.config/waybar/style.css

echo "Sway и Waybar установлены и настроены"
