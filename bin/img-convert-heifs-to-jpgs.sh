#!/bin/bash

echo -n "Checking the terminal ..." >&2 && [ -t 0 -a -t 2 ] && echo " OK" >&2 && \
    read -p "Are you sure you want to convert HEIF files in $PWD to JPEG and remove original HEIF files? " -n 1 && \
    [[ $REPLY =~ ^[Yy]$ ]] && echo >&2 || { echo " Exiting." >&2; exit 1; }

echo "Converting HEIF files in $PWD to JPEG files ... "

# mogrify -format jpg *.heif

find . -type f -and \( -iname "*.heif" \) \
     -exec sh -c 'for f do fbase=${f%.*} && [ ! -e "$fbase.jpg" ] && convert "$f" "$fbase.jpg" && rm "$f" || echo "Cannot convert file $f" ; done' sh {} +

echo "DONE."
