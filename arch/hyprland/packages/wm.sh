#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$(dirname "$(dirname "$DIR")")")"
source "$DIR/common.sh"

log "=== Установка Hyprland и Noctalia ==="
sudo pacman -S --needed --noconfirm \
    hyprland noctalia xdg-desktop-portal-hyprland \
    grim slurp wl-clipboard jq ddcutil \
    pipewire wireplumber pavucontrol brightnessctl \
    networkmanager network-manager-applet blueman xorg-xwayland \
    polkit-kde-agent \
    ttf-jetbrains-mono-nerd

log "=== Копирование конфига Hyprland ==="
mkdir -p ~/.config/hypr
# Hyprland 0.57+ читает только hyprland.lua; старый hyprland.conf игнорируется.
# Существующий conf не удаляем без следа — сохраняем как .legacy-0.56.
if [ -f ~/.config/hypr/hyprland.conf ] && [ ! -f ~/.config/hypr/hyprland.conf.legacy-0.56 ]; then
    mv ~/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf.legacy-0.56
fi
cp "$REPO/wm/hypr/hyprland.lua" ~/.config/hypr/hyprland.lua
cp "$REPO/wm/hypr/fix-monitor.sh" ~/.config/hypr/fix-monitor.sh
cp "$REPO/wm/hypr/fix-workspaces.sh" ~/.config/hypr/fix-workspaces.sh
chmod +x ~/.config/hypr/fix-monitor.sh ~/.config/hypr/fix-workspaces.sh
# подменяем захардкоженный /home/pc на домашний каталог текущего пользователя
sed -i "s|/home/pc|$HOME|g" ~/.config/hypr/hyprland.lua

log "=== Копирование vol.sh (громкость с дебаунсом для Noctalia OSD) ==="
mkdir -p ~/bin
cp "$REPO/wm/hypr/vol.sh" ~/bin/vol.sh
chmod +x ~/bin/vol.sh

log "=== Копирование конфига Noctalia ==="
mkdir -p ~/.config/noctalia
cp "$REPO/wm/noctalia/config.toml" ~/.config/noctalia/config.toml

log "=== Настройка GRUB (таймаут 2с) ==="
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=2/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

log "Hyprland и Noctalia установлены и настроены"
