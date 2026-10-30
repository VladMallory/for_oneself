#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Аварийный лёгкий сеанс: labwc (Wayland, ~670 КБ) ==="

# labwc — stacking-композитор на том же wlroots, что и sway.
# Конфиг не пересекается с Hyprland, поэтому при поломке hyprland.conf
# остаётся рабочий графический сеанс с терминалом (W+Return, правый клик).
sudo pacman -S --needed --noconfirm labwc

# labwc ищет терминал для W+Return по имени foot
if ! command -v foot &> /dev/null; then
    sudo pacman -S --needed --noconfirm foot
fi

if [[ ! -f /usr/share/wayland-sessions/labwc.desktop ]]; then
    log "ОШИБКА: labwc.desktop не найден, сессия не появится в ly"
    exit 1
fi

log "Готово! Сессия labwc доступна в ly (выбор сеанса)."
log "Аварийный вход: Ctrl+Alt+F2 → логин → labwc"
log "Внутри: W+Return — терминал, правый клик — меню, W+Q — закрыть окно."
