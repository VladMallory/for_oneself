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

log "=== Автозапуск hypridle в hyprland.conf ==="
# wm.sh копирует hyprland.conf из репозитория (там строка уже есть),
# это — страховка для случая, когда battery.sh запущен отдельно после wm.sh
if [ -f ~/.config/hypr/hyprland.conf ]; then
    if ! grep -q "^exec-once = hypridle" ~/.config/hypr/hyprland.conf; then
        printf '%s\n' "exec-once = hypridle  # автосон через 10 мин простоя (см. hypridle.conf)" >> ~/.config/hypr/hyprland.conf
        log "Строка автозапуска добавлена"
    else
        log "Строка автозапуска уже есть, пропускаем"
    fi
else
    log "hyprland.conf пока нет (его положит wm.sh из репозитория, строка уже в исходнике)"
fi

log "Автосон настроен: 5 мин (power-saver) / 10 мин (обычно)"
