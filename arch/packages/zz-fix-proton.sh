#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Фикс MIME-типов PortProton ==="

DESKTOP_FILE="/usr/share/applications/ru.linux_gaming.PortProton.desktop"
LOCAL_DESKTOP="$HOME/.local/share/applications/ru.linux_gaming.PortProton.desktop"

NEEDED_MIME="application/vnd.microsoft.portable-executable"

if [[ ! -f "$DESKTOP_FILE" ]]; then
    log "PortProton не установлен, пропускаем."
    exit 0
fi

mkdir -p "$HOME/.local/share/applications"

if [[ -f "$LOCAL_DESKTOP" ]]; then
    if grep -q "$NEEDED_MIME" "$LOCAL_DESKTOP"; then
        log "MIME-тип уже добавлен."
        exit 0
    fi
    cp "$LOCAL_DESKTOP" "$LOCAL_DESKTOP.bak"
else
    cp "$DESKTOP_FILE" "$LOCAL_DESKTOP"
fi

sed -i "s|application/x-ms-dos-executable;text/win-bat|application/x-ms-dos-executable;$NEEDED_MIME;text/win-bat|" "$LOCAL_DESKTOP"

update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null

xdg-mime default ru.linux_gaming.PortProton.desktop "$NEEDED_MIME" 2>/dev/null

log "MIME-тип $NEEDED_MIME добавлен. Готово!"
