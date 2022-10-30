#!/bin/bash

echo -n "Checking the terminal ..." >&2 && [ -t 0 -a -t 2 ] && echo " OK" >&2 && \
    read -p "Are you sure to remove EXIF info from JPG files in $PWD recursively? " -n 1 && \
    [[ $REPLY =~ ^[Yy]$ ]] && echo >&2 || { echo " Exiting." >&2; exit 1; }

echo "Removing EXIF info from JPG files in $PWD recursively ... "

find . -type f -and \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0 | \
    xargs -0 -I {} -P 3 \
          exiftool -all= '{}'

echo "DONE."
