#!/bin/bash
MCHOSE="alsa_output.usb-C-Media_Electronics_Inc_MCHOSE_V9_PRO_0123456789AB-01.analog-stereo"
SPEAKER="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"
EE_LINK="/home/pc/.local/bin/ee-mchose-link.sh"

prev=""
while true; do
    status=$(pactl list sinks short 2>/dev/null | grep "$MCHOSE" | awk '{print $NF}')
    if [ "$status" = "RUNNING" ] || [ "$status" = "SUSPENDED" ]; then
        if [ "$prev" != "connected" ]; then
            prev="connected"
            "$EE_LINK" 2>/dev/null
        fi
    else
        if [ "$prev" != "disconnected" ]; then
            prev="disconnected"
            pactl set-default-sink "$SPEAKER" 2>/dev/null
        fi
    fi
    sleep 2
done
