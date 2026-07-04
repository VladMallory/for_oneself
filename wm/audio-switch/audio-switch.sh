#!/bin/bash
MCHOSE="alsa_output.usb-C-Media_Electronics_Inc_MCHOSE_V9_PRO_0123456789AB-01.analog-stereo"
SPEAKER="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"
EE_LINK="/home/pc/.local/bin/ee-mchose-link.sh"
PACTL="/usr/bin/pactl"

$PACTL subscribe | while read -r event; do
    case "$event" in
        *"'remove' on sink"*)
            $PACTL list sinks short 2>/dev/null | grep -q "$MCHOSE" || {
                $PACTL set-default-sink "$SPEAKER" 2>/dev/null
            }
            ;;
        *"'new' on sink"*)
            $PACTL list sinks short 2>/dev/null | grep -q "$MCHOSE" && {
                "$EE_LINK" 2>/dev/null
            }
            ;;
    esac
done
