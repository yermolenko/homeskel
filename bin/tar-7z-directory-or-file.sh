#!/bin/bash

item=${1:?Name of the existing file or directory is required}
archive_filename=${2:-./`basename "$item"`.tar.7z}

[ -e "$item" ] || { echo "ERROR: \"$item\" does not exist"; exit 1; }

[ -e "$archive_filename" ] && { echo "ERROR: Destination already exists"; exit 1; }

tar --create --file - \
    --exclude-backups \
    --one-file-system --preserve-permissions --numeric-owner --sparse \
    "$item" | 7za a -mmt=off -si "$archive_filename"

if [ "${PIPESTATUS[*]}" != "0 0" ]; then
    echo "ERROR: Something went wrong"
fi

sync --file-system "$archive_filename"
