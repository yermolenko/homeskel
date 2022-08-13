#!/bin/bash

pacmd unload-module module-native-protocol-tcp
pacmd unload-module module-ladspa-sink
pacmd unload-module module-remap-sink

pa-enable-tcp.sh
pa-enable-mono-downmix.sh
