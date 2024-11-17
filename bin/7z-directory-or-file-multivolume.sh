#!/bin/bash

item=${1:?Name of the existing file or directory is required}
archive_filename=${2:-./`basename "$item"`.7z}

volume_size=${3:-4294967295b}

[ -e "$item" ] || { echo "ERROR: \"$item\" does not exist"; exit 1; }

[ -e "$archive_filename" ] && { echo "ERROR: Destination already exists"; exit 1; }
[ -e "$archive_filename.7z.001" ] && { echo "ERROR: Destination already exists"; exit 1; }

7z a -mmt=off -v"$volume_size" "$archive_filename" "$item"
