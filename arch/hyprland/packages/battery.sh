#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Пакеты для автосна (hypridle + power-profiles-daemon) ==="
sudo pacman -S --needed --noconfirm \
    hypridle power-profiles-daemon

log "=== Конфиг hypridle (сон: 5 мин в эко-режиме, 10 мин обычно) ==="
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hypridle.conf <<EOF
general {
}

# Эко-режим (power-saver): сон через 5 минут простоя
listener {
    timeout = 300
    on-timeout = systemctl suspend
    condition_cmd = $HOME/.config/hypr/is-eco.sh
    condition_retry = 15
}

# Обычный режим: сон через 10 минут простоя
listener {
    timeout = 600
    on-timeout = systemctl suspend
    condition_cmd = $HOME/.config/hypr/is-normal.sh
    condition_retry = 15
}
EOF

log "=== Скрипты-проверки профиля питания ==="
cat > ~/.config/hypr/is-eco.sh <<'EOF'
#!/bin/bash
# exit 0 = эко-режим активен (power-saver)
[ "$(powerprofilesctl get)" = "power-saver" ]
EOF
cat > ~/.config/hypr/is-normal.sh <<'EOF'
#!/bin/bash
# exit 0 = обычный режим (НЕ power-saver)
[ "$(powerprofilesctl get)" != "power-saver" ]
EOF
chmod +x ~/.config/hypr/is-eco.sh ~/.config/hypr/is-normal.sh

log "=== Проверка автозапуска hypridle в hyprland.lua ==="
# В Hyprland 0.57+ конфиг — Lua. hypridle уже прописан в автозапуске репозитория,
# это — страховка для случая, когда battery.sh запущен отдельно после wm.sh
if [ -f ~/.config/hypr/hyprland.lua ]; then
    if grep -q 'hl.exec_cmd("hypridle")' ~/.config/hypr/hyprland.lua; then
        log "hypridle уже в автозапуске, пропускаем"
    else
        log "ВНИМАНИЕ: в hyprland.lua нет hl.exec_cmd(\"hypridle\") — добавь вручную"
    fi
else
    log "hyprland.lua пока нет (его положит wm.sh из репозитория)"
fi

log "Автосон настроен: 5 мин (power-saver) / 10 мин (обычно)"
