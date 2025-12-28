#!/bin/bash

item=${1:?Name of the existing file or directory is required}
archive_filename=${2:-./`basename "$item"`.tar.gz}

[ -e "$item" ] || { echo "ERROR: \"$item\" does not exist"; exit 1; }

[ -e "$archive_filename" ] && { echo "ERROR: Destination already exists"; exit 1; }

tar --create --file "$archive_filename" \
    --exclude-backups \
    --use-compress-program gzip \
    --one-file-system --preserve-permissions --numeric-owner --sparse \
    "$item" || echo "ERROR: Something went wrong"

sync --file-system "$archive_filename"
