#!/bin/bash

output=LVDS
mode=1024x600
virtual_screen_size=1024x600

xrandr --output "$output" \
       --mode "$mode" \
       --fb "$virtual_screen_size" --panning "$virtual_screen_size"
