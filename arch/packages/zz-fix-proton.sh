#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Фикс MIME-типов PortProton ==="

SYS_FILE="/usr/share/applications/ru.linux_gaming.PortProton.desktop"
LOCAL_FILE="$HOME/.local/share/applications/ru.linux_gaming.PortProton.desktop"

MIME_LINE="MimeType=application/x-wine-extension-msp;application/x-msi;application/x-ms-dos-executable;application/x-msdownload;application/vnd.microsoft.portable-executable;text/win-bat;x-scheme-handler/portproton;"

if [[ ! -f "$SYS_FILE" ]]; then
    log "PortProton не установлен, пропускаем."
    exit 0
fi

mkdir -p "$HOME/.local/share/applications"

if [[ -f "$LOCAL_FILE" ]]; then
    if grep -q "application/x-msdownload" "$LOCAL_FILE" && grep -q "application/vnd.microsoft.portable-executable" "$LOCAL_FILE"; then
        log "MIME-типы уже добавлены."
        exit 0
    fi
    cp "$LOCAL_FILE" "$LOCAL_FILE.bak"
else
    cp "$SYS_FILE" "$LOCAL_FILE"
fi

sed -i "/^MimeType=/c\\$MIME_LINE" "$LOCAL_FILE"

update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null

for mime in "application/vnd.microsoft.portable-executable" "application/x-msdownload"; do
    xdg-mime default ru.linux_gaming.PortProton.desktop "$mime" 2>/dev/null
done

log "MIME-типы добавлены. Готово!"
