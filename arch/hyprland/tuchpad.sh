#!/usr/bin/env bash
#
# tuchpad.sh — быстрое устранение дрожания тачпада Goodix GXTP7863 (27C6:01E0)
# на Huawei MateBook под Linux (Hyprland / любой libinput-композитор).
#
# Причина дрожания: прошивка тачпада шлёт мелкий шум координат, а libinput
# не сглаживает его, потому что fuzz осей равен 0. Скрипт задаёт fuzz через
# udev/hwdb, из которого libinput берёт размер hysteresis.
#
# Использование:
#   ./tuchpad.sh apply [fuzz]   применить сглаживание (по умолчанию 16)
#   ./tuchpad.sh status         показать текущее состояние
#   ./tuchpad.sh remove         убрать сглаживание
#   ./tuchpad.sh help           справка
#
# fuzz — мёртвая зона в единицах тачпада. 16 ≈ 0.5 мм.
# Мало? попробуйте 24 или 32. Стало "липко"? уменьшите до 8.
#
set -uo pipefail

HWDB="/etc/udev/hwdb.d/61-goodix-gxtp7863-fuzz.hwdb"
HID_GLOB="0018:27C6:01E0.*"
DEFAULT_FUZZ=16
AXES=(00 01 35 36)

HID=""
DRV=""

die()  { printf 'Ошибка: %s\n' "$*" >&2; exit 1; }
info() { printf '%s\n' "$*"; }

usage() {
  cat <<'EOF'
Использование:
  tuchpad.sh apply [fuzz]   применить сглаживание (по умолчанию 16)
  tuchpad.sh status         показать текущее состояние
  tuchpad.sh remove         убрать сглаживание
  tuchpad.sh help           эта справка

fuzz — размер мёртвой зоны в единицах тачпада. 16 ≈ 0.5 мм.
Если дрожание осталось — попробуйте 24 или 32.
Если курсор стал "липким" — уменьшите до 8.
EOF
}

# ---------- root ----------
if [ "$(id -u)" -ne 0 ]; then
  SELF=$(readlink -f "$0")
  if [ -t 0 ] && command -v sudo >/dev/null 2>&1; then
    exec sudo -- "$SELF" "$@"
  elif command -v pkexec >/dev/null 2>&1; then
    exec pkexec /bin/bash -- "$SELF" "$@"
  else
    die "нужны права root (sudo или pkexec)"
  fi
fi

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# ---------- поиск устройств ----------
find_tp_event() {
  local inp ev
  for inp in /sys/class/input/input*; do
    [ -e "$inp/name" ] || continue
    grep -q 'GXTP7863' "$inp/name" 2>/dev/null || continue
    grep -q 'Touchpad' "$inp/name" 2>/dev/null || continue
    ev=$(ls "$inp" 2>/dev/null | grep '^event' | head -n1)
    if [ -n "$ev" ]; then
      printf '%s\n' "$ev"
      return 0
    fi
  done
  return 1
}

find_hid() {
  local d drv
  for d in /sys/bus/hid/devices/$HID_GLOB; do
    [ -e "$d" ] || continue
    drv=$(basename "$(readlink -f "$d/driver" 2>/dev/null)" 2>/dev/null || true)
    if [ "$drv" = "hid-multitouch" ]; then
      HID=$(basename "$d")
      DRV=$drv
      return 0
    fi
  done
  return 1
}

rebind_hid() {
  local i ev
  if ! find_hid; then
    info "HID-устройство не найдено — переподключение пропущено."
    return 0
  fi

  info "Переподключаю $HID ($DRV)..."
  printf '%s' "$HID" > "/sys/bus/hid/drivers/$DRV/unbind" 2>/dev/null || true

  for i in $(seq 1 30); do
    find_tp_event >/dev/null 2>&1 || break
    sleep 0.1
  done

  printf '%s' "$HID" > "/sys/bus/hid/drivers/$DRV/bind" 2>/dev/null || true

  for i in $(seq 1 40); do
    ev=$(find_tp_event) && { info "Тачпад вернулся: /dev/input/$ev"; return 0; }
    sleep 0.25
  done

  printf 'Внимание: тачпад не появился после переподключения. Перезагрузите ноутбук.\n' >&2
  return 1
}

# ---------- hwdb ----------
write_hwdb() {
  local fuzz=$1 ax
  {
    echo "# Goodix GXTP7863 (27C6:01E0) touchpad: suppress coordinate jitter."
    echo "# libinput hysteresis margin is taken from the kernel axis fuzz."
    echo "# Format: min:max:res:fuzz:flat (empty fields are left unchanged)."
    echo "evdev:input:b0018v27C6p01E0*"
    for ax in "${AXES[@]}"; do
      echo " EVDEV_ABS_${ax}=:::${fuzz}"
    done
  } > "$HWDB"
}

show_props() {
  local ev=$1
  udevadm info -q property "/dev/input/$ev" 2>/dev/null \
    | grep -E '^(ID_INPUT_TOUCHPAD|LIBINPUT_FUZZ_)' || true
}

# ---------- команды ----------
apply() {
  local fuzz=${1:-$DEFAULT_FUZZ}
  local ev props fz

  [[ "$fuzz" =~ ^[0-9]+$ ]] || die "fuzz должен быть целым числом"
  [ "$fuzz" -ge 1 ] && [ "$fuzz" -le 200 ] || die "fuzz должен быть от 1 до 200"

  write_hwdb "$fuzz"
  info "Обновляю hwdb..."
  systemd-hwdb update || die "systemd-hwdb update завершился с ошибкой"

  ev=$(find_tp_event) || die "тачпад GXTP7863 не найден"
  info "Триггер udev для $ev..."
  udevadm trigger --action=change --sysname-match="$ev" || true
  udevadm settle || true

  rebind_hid || true

  ev=$(find_tp_event) || die "тачпад не найден после переподключения"
  props=$(udevadm info -q property "/dev/input/$ev" 2>/dev/null || true)
  fz=$(printf '%s\n' "$props" | sed -n 's/^LIBINPUT_FUZZ_00=//p')

  echo
  info "Тачпад:        /dev/input/$ev"
  info "LIBINPUT_FUZZ: ${fz:-<не задан>}"
  if [ "${fz:-}" = "$fuzz" ]; then
    info "Готово: сглаживание fuzz=$fuzz включено."
    info "Hyprland уже переоткрыл устройство и применил hysteresis."
  else
    echo "Внимание: ожидался fuzz=$fuzz, а получен '${fz:-<нет>}'." >&2
    echo "Если не заработает — перезагрузите ноутбук и проверьте: $0 status" >&2
    return 1
  fi
}

status() {
  local ev uid log last_add jumps

  echo "=== hwdb-файл ==="
  if [ -f "$HWDB" ]; then
    sed 's/^/  /' "$HWDB"
  else
    echo "  (не создан — сглаживание выключено)"
  fi
  echo

  ev=$(find_tp_event) || { echo "Тачпад GXTP7863 не найден."; return 1; }
  echo "=== устройство ==="
  echo "  /dev/input/$ev"
  show_props "$ev" | sed 's/^/  /'
  echo

  echo "=== Hyprland ==="
  uid=${SUDO_UID:-${PKEXEC_UID:-$(id -u)}}
  log=$(ls /run/user/"$uid"/hypr/*/hyprland.log 2>/dev/null | head -n1)
  if [ -n "$log" ]; then
    if grep -q 'hysteresis enabled' "$log"; then
      echo "  hysteresis: включён (libinput)"
    else
      echo "  hysteresis: в логе не найден"
    fi
    last_add=$(grep -n 'device is a touchpad' "$log" | tail -n1 | cut -d: -f1)
    if [ -n "$last_add" ]; then
      jumps=$(awk -v n="$last_add" 'NR > n && /jump detected/' "$log" | wc -l)
      echo "  Touch jump после последнего подключения: $jumps"
    fi
    echo "  лог: $log"
  else
    echo "  лог Hyprland не найден (не Hyprland или другая сессия)"
  fi
}

remove_fix() {
  local ev fz

  if [ -f "$HWDB" ]; then
    rm -f "$HWDB"
    info "Удалён $HWDB"
  else
    info "Файл уже отсутствует."
  fi

  systemd-hwdb update || true

  ev=$(find_tp_event) && {
    udevadm trigger --action=change --sysname-match="$ev" || true
    udevadm settle || true
  }

  rebind_hid || true

  ev=$(find_tp_event) && {
    fz=$(udevadm info -q property "/dev/input/$ev" 2>/dev/null | sed -n 's/^LIBINPUT_FUZZ_00=//p')
    info "LIBINPUT_FUZZ_00=${fz:-<не задан>}"
  }

  info "Сглаживание отключено."
}

cmd=${1:-help}
case "$cmd" in
  apply)  shift; apply "$@" ;;
  status) status ;;
  remove) remove_fix ;;
  help|-h|--help) usage ;;
  *) usage; exit 1 ;;
esac
