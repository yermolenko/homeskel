#!/bin/bash

x11_server_display=${1:-:0}
vnc_port=${2:-5900}

if [ "$EUID" -eq 0 ]
then
    find /var/run/sddm/ -type f -print0 | \
        xargs -0 -I {} \
              x11vnc -auth '{}' \
              -display $x11_server_display -localhost -rfbport $vnc_port -quiet -many -noxdamage
else
    x11vnc -auth /home/`whoami`/.Xauthority \
           -display $x11_server_display -localhost -rfbport $vnc_port -quiet -many -noxdamage
fi
