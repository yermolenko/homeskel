#!/bin/bash

[ -e /usr/lib/ladspa ] || echo "NOTE: make sure swh-plugins are installed"

pacmd load-module module-ladspa-sink sink_name=compressor plugin=sc4m_1916 label=sc4m control=1,1.5,401,-30,20,5,12 && \
    pacmd set-default-sink compressor
