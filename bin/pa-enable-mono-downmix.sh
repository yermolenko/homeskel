#!/bin/bash

alsa_sink=$(pacmd list-sinks | grep "name: <" | grep alsa_output)

alsa_sink=${alsa_sink#*<}
alsa_sink=${alsa_sink%>*}
[ -z "$alsa_sink" ] && { echo "Cannot determine alsa sink"; exit 1; }

pacmd load-module module-remap-sink master=$alsa_sink sink_name=mono sink_properties="device.description='Mono'" channels=2 channel_map=mono,mono && \
    pacmd set-default-sink mono
