#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$(dirname "$(dirname "$DIR")")")"
source "$DIR/common.sh"

log "=== Установка logiops (драйвер Logitech MX Master) ==="
yay -S --needed --noconfirm logiops

log "=== Деплой /etc/logid.cfg ==="
sudo cp "$REPO/wm/logiops/logid.cfg" /etc/logid.cfg

log "=== Включение logid.service ==="
sudo systemctl enable --now logid.service

log "logiops готов (кнопка Вперед -> средняя кнопка)"
