#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Настройка автологина в ly ==="

sudo sed -i 's/^auto_login_session = null$/auto_login_session = sway/' /etc/ly/config.ini
sudo sed -i 's/^auto_login_user = null$/auto_login_user = pc/' /etc/ly/config.ini

log "=== Автологин pc в sway включён ==="
