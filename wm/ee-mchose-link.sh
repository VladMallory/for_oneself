#!/bin/bash
SINK="alsa_output.usb-C-Media_Electronics_Inc_MCHOSE_V9_PRO_0123456789AB-01.analog-stereo"
sleep 3
pw-link easyeffects_sink:monitor_FL "$SINK":playback_FL 2>/dev/null
pw-link easyeffects_sink:monitor_FR "$SINK":playback_FR 2>/dev/null
pactl set-default-sink easyeffects_sink 2>/dev/null
wpctl set-volume -l 1.0 0 100% 2>/dev/null
pactl set-default-source easyeffects_source 2>/dev/null
wpctl set-volume -l 1.0 169 100% 2>/dev/null
