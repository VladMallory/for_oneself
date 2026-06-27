#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Фикс PortProton (MIME-типы + DISPLAY) ==="

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
