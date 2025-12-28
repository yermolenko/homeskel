#!/bin/bash

item=${1:?Name of the existing file or directory is required}
archive_filename=${2:-./`basename "$item"`.zip}

[ -e "$item" ] || { echo "ERROR: \"$item\" does not exist"; exit 1; }

[ -e "$archive_filename" ] && { echo "ERROR: Destination already exists"; exit 1; }
[ -e "$archive_filename.zip" ] && { echo "ERROR: Destination already exists"; exit 1; }

zip -r "$archive_filename" "$item" || echo "ERROR: Something went wrong"

sync --file-system "$archive_filename"
