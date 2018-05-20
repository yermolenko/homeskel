#!/bin/bash

read -p "Are you sure to remove EXIF info from JPG files in $PWD recursively? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo ""
    exit 1
fi

echo ""
echo -n "Removing EXIF info from JPG files in $PWD recursively ... "

find . -type f -iname '*.jpg' -print0 | \
    xargs -0 -I {} -P 3 \
          exiftool -all= '{}'

echo "DONE."
