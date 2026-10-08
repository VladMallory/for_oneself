#!/bin/bash
# fix-monitor.sh — кнопка "починить столы" (бинд ALT+SHIFT+F).
# - HDMI подключен -> ЗЕРКАЛО: HDMI основной 1440p, eDP дублирует его.
#   Одна картинка везде, столы никогда не застревают на другом экране.
# - HDMI выдернут -> только eDP + подбор осиротевших столов.
# Использование вручную или по бинду.

HDMI_CONNECTED=0
for f in /sys/class/drm/*-HDMI-A-1/status; do
  grep -qx "connected" "$f" 2>/dev/null && HDMI_CONNECTED=1 && break
done

if [ "$HDMI_CONNECTED" = "1" ]; then
  echo "HDMI подключен -> включаю зеркало (eDP дублирует HDMI)"
  hyprctl keyword monitor "HDMI-A-1,2560x1440@74.96,0x0,1" >/dev/null
  hyprctl keyword monitor "eDP-1,preferred,0x0,1,mirror,HDMI-A-1" >/dev/null
  sleep 0.5
else
  echo "HDMI выдернут -> только eDP"
  hyprctl keyword monitor "eDP-1,preferred,0x0,1" >/dev/null
  sleep 0.5
  for ws in $(hyprctl workspaces -j 2>/dev/null | jq -r '.[] | select(.monitorID==null) | .id'); do
    echo "чиню воркспейс $ws -> eDP-1"
    hyprctl dispatch moveworkspacetomonitor "$ws" eDP-1 >/dev/null
  done
fi
hyprctl monitors 2>&1 | grep -E "^Monitor|mirrorOf"
hyprctl workspaces 2>&1 | grep -E "^workspace ID"
