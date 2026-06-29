#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Фикс PortProton (MIME-типы + DISPLAY + 32-bit deps) ==="

log "Смена зеркала Flathub на Яндекс..."
flatpak remote-modify flathub --url=https://mirror.yandex.ru/mirrors/flathub 2>/dev/null || true
flatpak remotes -d 2>/dev/null || true

log "Установка 32-битных зависимостей для Wine/Proton..."
LIBS32=(
    lib32-vulkan-icd-loader lib32-giflib lib32-libpng lib32-libldap
    lib32-gnutls lib32-mpg123 lib32-lcms2 lib32-libjpeg-turbo
    lib32-libogg lib32-libvorbis lib32-mesa lib32-sdl2
    lib32-gst-plugins-base lib32-gst-plugins-good lib32-pipewire
    lib32-alsa-lib lib32-alsa-plugins lib32-libpulse
    lib32-libxcomposite lib32-libxinerama lib32-libxslt
    lib32-openal lib32-libxdamage lib32-libxrandr
    lib32-dbus lib32-libxcrypt lib32-expat
)
MISSING=()
for pkg in "${LIBS32[@]}"; do
    pacman -Q "$pkg" &>/dev/null || MISSING+=("$pkg")
done
if [[ ${#MISSING[@]} -gt 0 ]]; then
    sudo pacman -S --noconfirm "${MISSING[@]}" && log "  Установлено: ${MISSING[*]}"
else
    log "  Все 32-битные библиотеки уже установлены."
fi

GPU=$(lspci -k | grep -A3 "VGA\|3D" | grep -oP '(Intel|AMD|NVIDIA)' | head -1)
case "$GPU" in
    Intel) sudo pacman -S --noconfirm lib32-vulkan-intel &>/dev/null ;;
    AMD)   sudo pacman -S --noconfirm lib32-vulkan-radeon &>/dev/null ;;
    NVIDIA) sudo pacman -S --noconfirm lib32-nvidia-utils &>/dev/null ;;
esac

log "Фикс 32-битного Vulkan ICD..."
for json in /usr/share/vulkan/icd.d/*.json; do
    base="${json%.json}"
    i686="${base}.i686.json"
    if [[ -f "$json" && ! -f "$i686" && "$json" != *".i686.json" ]]; then
        sudo cp "$json" "$i686" 2>/dev/null && log "  Создан $i686"
    fi
done

SYS_FILE="/usr/share/applications/ru.linux_gaming.PortProton.desktop"
LOCAL_FILE="$HOME/.local/share/applications/ru.linux_gaming.PortProton.desktop"

if [[ ! -f "$SYS_FILE" ]]; then
    log "PortProton не установлен, пропускаем."
    exit 0
fi

mkdir -p "$HOME/.local/share/applications"
cp "$SYS_FILE" "$LOCAL_FILE"

sed -i \
  -e "s|^Exec=portproton %u|Exec=env DISPLAY=:0 portproton %f|" \
  -e "s|^MimeType=.*|MimeType=application/x-wine-extension-msp;application/x-msi;application/x-ms-dos-executable;application/x-msdownload;application/vnd.microsoft.portable-executable;text/win-bat;x-scheme-handler/portproton;|" \
  "$LOCAL_FILE"

update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null

for mime in "application/vnd.microsoft.portable-executable" "application/x-msdownload"; do
    xdg-mime default ru.linux_gaming.PortProton.desktop "$mime" 2>/dev/null
done

log "Готово!"
