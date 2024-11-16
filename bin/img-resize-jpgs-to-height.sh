#!/bin/bash

height=${1:-1080}

echo -n "Checking the terminal ..." >&2 && [ -t 0 -a -t 2 ] && echo " OK" >&2 && \
    read -p "Are you sure you want to resize JPG files in $PWD to height of $height px? " -n 1 && \
    [[ $REPLY =~ ^[Yy]$ ]] && echo >&2 || { echo " Exiting." >&2; exit 1; }

echo "Resizing JPG files in $PWD to height of $height px ... "

find . -type f -and \( -iname "*.jpg" -o -iname "*.jpeg" \) \
     -exec sh -c "mv \"{}\" \"{}.tmp.jpg\" && convert \"{}.tmp.jpg\" -units PixelsPerInch -density 100 -resize \"x$height\" \"{}\" && rm \"{}.tmp.jpg\"" \;

echo "DONE."
