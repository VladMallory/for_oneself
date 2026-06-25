#!/bin/bash
# Generate archinstall-config.json with auto-detected disk and correct sizes.
# Run as root on Arch ISO BEFORE archinstall.
#   bash gen-config.sh
#   archinstall --config archinstall-config.json --creds archinstall-creds.json

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$DIR/archinstall-config.json"

# --- detect first non-loop disk (prefer NVMe) ---
detect_disk() {
    lsblk -d -o NAME,SIZE,TYPE -J -p 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
disks = [d for d in data['blockdevices'] if d['type'] == 'disk']
# sort: nvme first, then others
disks.sort(key=lambda d: 0 if 'nvme' in d['name'] else 1)
if not disks:
    print('', end='')
    sys.exit(1)
print(disks[0]['name'], disks[0]['size'])
" || {
        echo "ERROR: no disk detected" >&2
        exit 1
    }
}

read DEVICE SIZE_RAW <<< "$(detect_disk)"
echo "Detected: $DEVICE  $SIZE_RAW" >&2

# --- parse size to MiB ---
parse_mib() {
    local val="$1"
    local num="${val%[A-Z]}"
    local unit="${val: -1}"
    case "$unit" in
        K) echo "$(LC_NUMERIC=C printf "%.0f" "$(echo "$num * 1" | bc -l)")" ;;
        M) echo "$(LC_NUMERIC=C printf "%.0f" "$(echo "$num * 1" | bc -l)")" ;;
        G) echo "$(LC_NUMERIC=C printf "%.0f" "$(echo "$num * 1024" | bc -l)")" ;;
        T) echo "$(LC_NUMERIC=C printf "%.0f" "$(echo "$num * 1048576" | bc -l)")" ;;
        *) echo "ERROR: unknown unit $unit" >&2; exit 1 ;;
    esac
}

TOTAL_MIB=$(parse_mib "$SIZE_RAW")

# --- partition sizes in MiB ---
BOOT_MIB=1024
SWAP_MIB=$((20 * 1024))
BOOT_START=1
SWAP_START=$((BOOT_START + BOOT_MIB))
ROOT_START=$((SWAP_START + SWAP_MIB))
ROOT_START_MIB=$ROOT_START
AVAILABLE=$((TOTAL_MIB - 1))  # 1 MiB for GPT backup
ROOT_MIB=$((AVAILABLE - ROOT_START))

echo "Layout: ${BOOT_MIB}MiB boot + ${SWAP_MIB}MiB swap + ${ROOT_MIB}MiB root (${TOTAL_MIB}MiB total)" >&2

# --- generate JSON ---
cat > "$OUT" <<JSONEOF
{
  "archinstall-language": "English",
  "audio_config": { "audio": "pipewire" },
  "bootloader_config": {
    "bootloader": "Grub",
    "uki": false,
    "removable": false
  },
  "debug": false,
  "disk_config": {
    "config_type": "default_layout",
    "device_modifications": [
      {
        "device": "$DEVICE",
        "partitions": [
          {
            "btrfs": [],
            "flags": ["boot", "esp"],
            "fs_type": "fat32",
            "size": { "sector_size": { "value": 512, "unit": "B" }, "unit": "MiB", "value": $BOOT_MIB },
            "mount_options": [],
            "mountpoint": "/boot",
            "start": { "sector_size": { "value": 512, "unit": "B" }, "unit": "MiB", "value": $BOOT_START },
            "status": "create",
            "type": "primary",
            "dev_path": null,
            "obj_id": "11111111-1111-1111-1111-111111111111"
          },
          {
            "btrfs": [],
            "flags": ["swap"],
            "fs_type": "linux-swap",
            "size": { "sector_size": { "value": 512, "unit": "B" }, "unit": "MiB", "value": $SWAP_MIB },
            "mount_options": [],
            "mountpoint": null,
            "start": { "sector_size": { "value": 512, "unit": "B" }, "unit": "MiB", "value": $SWAP_START },
            "status": "create",
            "type": "primary",
            "dev_path": null,
            "obj_id": "22222222-2222-2222-2222-222222222222"
          },
          {
            "btrfs": [],
            "flags": [],
            "fs_type": "ext4",
            "size": { "sector_size": { "value": 512, "unit": "B" }, "unit": "MiB", "value": $ROOT_MIB },
            "mount_options": [],
            "mountpoint": "/",
            "start": { "sector_size": { "value": 512, "unit": "B" }, "unit": "MiB", "value": $ROOT_START },
            "status": "create",
            "type": "primary",
            "dev_path": null,
            "obj_id": "33333333-3333-3333-3333-333333333333"
          }
        ],
        "wipe": true
      }
    ]
  },
  "hostname": "arch-pc",
  "kernels": ["linux"],
  "locale_config": {
    "kb_layout": "us",
    "sys_enc": "UTF-8",
    "sys_lang": "ru_RU"
  },
  "mirror_config": {
    "mirror_regions": { "Russia": [] },
    "optional_repositories": ["multilib"]
  },
  "network_config": { "type": "nm" },
  "no_pkg_lookups": false,
  "ntp": true,
  "offline": false,
  "packages": ["bluez", "bluez-utils", "cups", "cups-pdf", "print-manager", "system-config-printer"],
  "pacman_config": {
    "color": true,
    "parallel_downloads": 10
  },
  "profile_config": {
        "profile": { "details": ["Sway"], "main": "Desktop" },
        "gfx_driver": "Intel (open-source)",
        "greeter": "ly"
  },
  "script": "guided",
  "silent": false,
  "swap": false,
  "timezone": "Asia/Vladivostok",
  "version": "2.8.6"
}
JSONEOF

echo "Generated: $OUT" >&2
