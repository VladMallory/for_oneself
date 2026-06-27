#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== 1. Подключение репозитория Flathub ==="
if ! flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
    echo "Flathub недоступен (возможно блокировка в РФ). Всё остальное уже установлено."
    exit 0
fi

log "=== 2. Установка Flatpak приложений ==="
apps=(
    com.github.tchx84.Flatseal
)

# Установка всех приложений для текущего пользователя
for app in "${apps[@]}"; do
    echo "Установка $app..."
    flatpak install --user -y flathub "$app" || echo "Не удалось установить $app, пропускаем..."
done

log "=== Flatpak приложения успешно установлены! ==="
