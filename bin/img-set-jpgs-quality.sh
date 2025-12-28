#!/bin/bash

quality=${1:-92}

echo -n "Checking the terminal ..." >&2 && [ -t 0 -a -t 2 ] && echo " OK" >&2 && \
    read -p "Are you sure you want to set JPG files quality to $quality? " -n 1 && \
    [[ $REPLY =~ ^[Yy]$ ]] && echo >&2 || { echo " Exiting." >&2; exit 1; }

echo "Setting JPG files quality to $quality ... "

find . -type f -and \( -iname "*.jpg" -o -iname "*.jpeg" \) \
     -exec sh -c "mv \"{}\" \"{}.tmp.jpg\" && convert \"{}.tmp.jpg\" -quality $quality \"{}\" && rm \"{}.tmp.jpg\"" \;

echo "DONE."
