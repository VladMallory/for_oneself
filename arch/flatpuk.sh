#!/bin/bash

set -e

echo "=== 1. Подключение репозитория Flathub ==="
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "=== 2. Установка Flatpak приложений ==="
apps=(
    chat.simplex.simplex
    com.anydesk.Anydesk
    com.axosoft.GitKraken
    com.bitwarden.desktop
    com.brave.Browser
    com.getpostman.Postman
    com.github.tchx84.Flatseal
    com.github.wwmm.easyeffects
    com.obsproject.Studio
    com.termius.Termius
    im.riot.Riot
    io.github.Fndroid.clash_for_windows
    io.github.thetumultuousunicornofdarkness.cpu-x
    io.podman_desktop.PodmanDesktop
    md.obsidian.Obsidian
    net.lutris.Lutris
    org.freedesktop.LinuxAudio.Plugins.Calf
    org.freedesktop.LinuxAudio.Plugins.LSP
    org.freedesktop.LinuxAudio.Plugins.MDA
    org.freedesktop.LinuxAudio.Plugins.ZamPlugins
    org.freedesktop.LinuxAudio.Plugins.x42Plugins
    org.qbittorrent.qBittorrent
    org.signal.Signal
    org.telegram.desktop
    org.videolan.VLC
    ru.linux_gaming.PortProton
    ru.yandex.Browser
)

# Установка всех приложений для текущего пользователя
for app in "${apps[@]}"; do
    echo "Установка $app..."
    flatpak install --user -y flathub "$app" || echo "Не удалось установить $app, пропускаем..."
done

echo "=== Flatpak приложения успешно установлены! ==="
