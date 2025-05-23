#!/bin/sh

RECORD_PID_FILE="/tmp/wf-recording.pid"
AUDIO_SOURCE="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink.monitor"

# Function to stop recording
stop_recording() {
    if [ -f "$RECORD_PID_FILE" ]; then
        kill -INT "$(cat "$RECORD_PID_FILE")" 2>/dev/null && rm -f "$RECORD_PID_FILE"
    fi
}

# If already recording, stop it
if [ -f "$RECORD_PID_FILE" ] && kill -0 "$(cat "$RECORD_PID_FILE")" 2>/dev/null; then
    stop_recording
    exit 0
fi

# Otherwise, start recording
geometry="$(slurp -d)"
if [ -n "$geometry" ]; then
    pkill -USR1 -x record-screend
    mkdir -p ~/Videos/Recordings
    wf-recorder \
        -f ~/Videos/Recordings/"screen-record-$(date +%Y-%m-%d-%H-%M-%S).mp4" \
        -g "$geometry" \
        --audio \
        --audio-source="$AUDIO_SOURCE" &
    echo $! > "$RECORD_PID_FILE"
    pkill -USR2 -x record-screend
fi

