#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Настройка автологина в ly ==="

LOGIN_USER="${SUDO_USER:-$USER}"

sudo sed -i 's/^auto_login_session = .*$/auto_login_session = hyprland/' /etc/ly/config.ini
sudo sed -i "s/^auto_login_user = .*$/auto_login_user = $LOGIN_USER/" /etc/ly/config.ini

log "=== Автологин $LOGIN_USER в hyprland включён ==="
