#!/usr/bin/env bash
set -e

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/theme-state"

if [[ -f "$STATE_FILE" ]]; then
  current=$(cat "$STATE_FILE")
else
  current="dark"
fi

if [[ "$current" == "dark" ]]; then
  echo "→ Light theme"
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface color-scheme "prefer-light" 2>/dev/null || true
  echo "light" > "$STATE_FILE"
else
  echo "→ Dark theme"
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita:dark" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true
  echo "dark" > "$STATE_FILE"
fi

