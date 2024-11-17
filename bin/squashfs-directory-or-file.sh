#!/bin/bash

item=${1:?Name of the existing file or directory is required}
archive_filename=${2:-./`basename "$item"`.squashfs}

[ -e "$item" ] || { echo "ERROR: \"$item\" does not exist"; exit 1; }

[ -e "$archive_filename" ] && { echo "ERROR: Destination already exists"; exit 1; }

mksquashfs "$item" "$archive_filename" -processors 2 -comp xz
