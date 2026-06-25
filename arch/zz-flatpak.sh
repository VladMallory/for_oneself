#!/bin/bash

echo "=== 1. Подключение репозитория Flathub ==="
if ! flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
    echo "Flathub недоступен (возможно блокировка в РФ). Всё остальное уже установлено."
    exit 0
fi

echo "=== 2. Установка Flatpak приложений ==="
apps=(
    com.anydesk.Anydesk
    com.bitwarden.desktop
    com.brave.Browser
    com.getpostman.Postman
    com.github.tchx84.Flatseal
    com.github.wwmm.easyeffects
    com.obsproject.Studio
    com.termius.Termius
    im.riot.Riot
    md.obsidian.Obsidian
    org.qbittorrent.qBittorrent
    org.signal.Signal
    org.telegram.desktop
    org.videolan.VLC
    ru.linux_gaming.PortProton
)

# Установка всех приложений для текущего пользователя
for app in "${apps[@]}"; do
    echo "Установка $app..."
    flatpak install --user -y flathub "$app" || echo "Не удалось установить $app, пропускаем..."
done

echo "=== Flatpak приложения успешно установлены! ==="
