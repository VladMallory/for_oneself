#!/bin/bash
# Дебаунс для громкости: клавиша громкости прилетает дважды
# (AT keyboard + Huawei WMI hotkeys / CX 2.4G ресивер), Hyprland
# запускает bind дважды. Дубликат прилетает за ~5-30мс, живое
# двойное нажатие — от ~150мс, поэтому окно всего 100мс:
# проверка+запись метки атомарно под flock, сама команда
# выполняется уже без лока (не тормозит повторы/даблклики).
THRESH_MS=100
LAST_FILE=/tmp/vol.last

(
  flock -n 9 || exit 0
  NOW=$(date +%s%N)
  LAST=$(cat "$LAST_FILE" 2>/dev/null || echo 0)
  if [ "$LAST" != "0" ]; then
    DIFF_MS=$(( (NOW - LAST) / 1000000 ))
    if [ "$DIFF_MS" -lt "$THRESH_MS" ]; then exit 0; fi
    echo "$NOW" > "$LAST_FILE"
    exit 10
  fi
  echo "$NOW" > "$LAST_FILE"
  exit 10
) 9>/tmp/noctalia-vol.lock
[ "$?" -eq 10 ] || exit 0

case "$1" in
  up)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 2>/dev/null
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.3 2>/dev/null
    exec noctalia msg volume-osd ;;
  down)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- 2>/dev/null
    exec noctalia msg volume-osd ;;
  mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle 2>/dev/null
    exec noctalia msg volume-osd ;;
  *)    echo "usage: $0 up|down|mute" >&2; exit 1 ;;
esac
