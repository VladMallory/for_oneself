#!/bin/bash
# Toggle between USB audio (MCHOSE V9 PRO) and built-in Speaker

USB_SINK_NAME="alsa_output.usb-C-Media_Electronics_Inc_MCHOSE_V9_PRO_0123456789AB-01.analog-stereo"
USB_SINK_ID=$(pactl list sinks short 2>/dev/null | grep "$USB_SINK_NAME" | awk '{print $1}')

CARD="alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic"
SPK_SINK_NAME="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"

ALSA_CARD=1
for c in 0 1 2; do
    amixer -c$c controls 2>/dev/null | grep -q "Headphone Playback Switch" && ALSA_CARD=$c && break
done

# Detect current active sink
ACTIVE_SINK=$(pactl list sinks short 2>/dev/null | grep RUNNING | awk '{print $2}' | head -1)
if [ -z "$ACTIVE_SINK" ]; then
    ACTIVE_SINK=$(pactl get-default-sink 2>/dev/null)
fi
echo "Current: $ACTIVE_SINK"

move_streams() {
    local target_name="$1" target_id="$2" label="$3"
    pw-metadata -n default 0 default.audio.sink "Spa:String:JSON" "{\"name\":\"$target_name\"}" 2>/dev/null
    pactl set-default-sink "$target_name" 2>/dev/null
    pactl set-sink-volume "$target_name" 100% 2>/dev/null
    pactl set-sink-mute "$target_name" 0 2>/dev/null
    sleep 0.3
    for input in $(pactl list sink-inputs short 2>/dev/null | awk '{print $1}'); do
        local cur=$(pactl list sink-inputs 2>/dev/null | grep -A 20 "Sink Input #$input" | grep "Sink: " | head -1 | awk '{print $2}')
        if [ -n "$cur" ] && [ "$cur" != "$target_id" ]; then
            pactl move-sink-input "$input" "$target_name" 2>/dev/null
            echo "Moved stream $input -> $label"
        fi
    done
}

if echo "$ACTIVE_SINK" | grep -q "usb-C-Media"; then
    # Currently on USB → switch to built-in Speaker
    TARGET="Speaker"
    echo "Target: $TARGET"

    amixer -c$ALSA_CARD cset numid=7 0 2>/dev/null
    amixer -c$ALSA_CARD cset numid=4 "off" 2>/dev/null
    amixer -c$ALSA_CARD cset numid=3 74 2>/dev/null
    amixer -c$ALSA_CARD cset numid=6 "on" 2>/dev/null
    pactl set-card-profile "$CARD" "HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)"

    HW_NAME=""; HW_ID=""
    for i in $(seq 1 10); do
        HW_ID=$(pactl list sinks short 2>/dev/null | grep "Speaker" | grep -v "Headphone" | awk '{print $1}' | head -1)
        [ -n "$HW_ID" ] && break
        sleep 0.5
    done
    HW_NAME=$(pactl list sinks short 2>/dev/null | grep "Speaker" | grep -v "Headphone" | awk '{print $2}' | head -1)

    if [ -n "$HW_NAME" ]; then
        echo "Sink: $HW_NAME (id=$HW_ID)"
        move_streams "$HW_NAME" "$HW_ID" "$TARGET"
    fi
else
    # Currently on built-in audio (Speaker or Headphones) → switch to USB
    TARGET="USB"
    echo "Target: $TARGET"

    amixer -c$ALSA_CARD cset numid=7 0 2>/dev/null
    amixer -c$ALSA_CARD cset numid=4 "off" 2>/dev/null
    amixer -c$ALSA_CARD cset numid=3 74 2>/dev/null
    amixer -c$ALSA_CARD cset numid=6 "on" 2>/dev/null
    pactl set-card-profile "$CARD" "HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)"

    if [ -n "$USB_SINK_ID" ]; then
        echo "Sink: $USB_SINK_NAME (id=$USB_SINK_ID)"
        move_streams "$USB_SINK_NAME" "$USB_SINK_ID" "$TARGET"
    fi
fi

echo "Done: $TARGET"

