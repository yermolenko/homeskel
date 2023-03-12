#!/bin/bash

output=DVI-D-0
mode=1024x768
virtual_screen_size=1920x1200

xrandr --output "$output" \
       --mode "$mode" \
       --fb "$virtual_screen_size" --panning "$virtual_screen_size"
