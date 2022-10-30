#!/bin/bash

max_size=${1:-1000}

echo -n "Checking the terminal ..." >&2 && [ -t 0 -a -t 2 ] && echo " OK" >&2 && \
    read -p "Are you sure you want to resize PNG files in $PWD to max $max_size px? " -n 1 && \
    [[ $REPLY =~ ^[Yy]$ ]] && echo >&2 || { echo " Exiting." >&2; exit 1; }

echo "Resizing PNG files in $PWD to max $max_size px ... "

find . -type f -and \( -iname "*.png" \) \
     -exec sh -c "mv \"{}\" \"{}.tmp.png\" && convert \"{}.tmp.png\" -units PixelsPerInch -density 100 -resize \"$max_size>\" \"{}\" && rm \"{}.tmp.png\"" \;

echo "DONE."
