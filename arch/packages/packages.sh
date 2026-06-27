#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Системные пакеты ==="
sudo pacman -S --needed --noconfirm \
    btop fastfetch ffmpeg rsync tree wget unzip firefox \
    thunar qalculate-gtk baobab qbittorrent flatpak \
    telegram-desktop vlc obs-studio easyeffects element-desktop \
    signal-desktop bitwarden steam

log "=== AUR пакеты ==="
if ! command -v flclash &> /dev/null; then
    yay -S --needed --noconfirm flclash-bin localsend-bin obsidian-bin brave-bin anydesk-bin postman-bin portproton termius
fi

log "Пакеты установлены"
