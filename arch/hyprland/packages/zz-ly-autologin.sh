#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Настройка автологина в ly ==="

# SUDO_USER может быть root (например, при sudo -u pc из root),
# поэтому root всегда пропускаем и ищем обычного пользователя.
detect_user() {
    local u
    for u in "${SUDO_USER:-}" "$(logname 2>/dev/null || true)" "$USER"; do
        if [ -n "$u" ] && [ "$u" != "root" ] && id "$u" >/dev/null 2>&1; then
            echo "$u"
            return 0
        fi
    done
    awk -F: '$3 >= 1000 && $3 < 65534 {print $1; exit}' /etc/passwd
}

LOGIN_USER="$(detect_user)"

if [ -z "$LOGIN_USER" ] || [ "$LOGIN_USER" = "root" ]; then
    log "ОШИБКА: не удалось определить пользователя для автологина"
    exit 1
fi

sudo sed -i 's/^auto_login_session = .*$/auto_login_session = hyprland/' /etc/ly/config.ini
sudo sed -i "s/^auto_login_user = .*$/auto_login_user = $LOGIN_USER/" /etc/ly/config.ini

log "=== Автологин $LOGIN_USER в hyprland включён ==="
