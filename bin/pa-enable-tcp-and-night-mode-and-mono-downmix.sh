#!/bin/bash

pacmd unload-module module-native-protocol-tcp
pacmd unload-module module-ladspa-sink
pacmd unload-module module-remap-sink

pacmd load-module module-native-protocol-tcp

[ -e /usr/lib/ladspa ] || echo "NOTE: make sure swh-plugins are installed"

pacmd load-module module-ladspa-sink sink_name=compressor plugin=sc4m_1916 label=sc4m control=1,1.5,401,-30,20,5,12 && \
    pacmd set-default-sink compressor

pacmd load-module module-remap-sink master=compressor sink_name=mono sink_properties="device.description='Mono'" channels=2 channel_map=mono,mono && \
    pacmd set-default-sink mono
