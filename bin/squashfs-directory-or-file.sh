#!/bin/bash

item=${1:?Name of the existing file or directory is required}
archive_filename=${2:-./`basename "$item"`.squashfs}

[ -e "$item" ] || { echo "ERROR: \"$item\" does not exist"; exit 1; }

[ -e "$archive_filename" ] && \
    {
        echo "WARNING: Destination already exists";

        echo -n "Checking the terminal ..." >&2 && [ -t 0 -a -t 2 ] && echo " OK" >&2 && \
            read -p "Are you sure to APPEND to the existing squashfs? " -n 1 && \
            [[ $REPLY =~ ^[Yy]$ ]] && echo >&2 || { echo " Exiting." >&2; exit 1; }

        echo ""
        echo  "Appending to the existing squashfs ... "
    }

mksquashfs "$item" "$archive_filename" -processors 2 -comp xz

sync --file-system "$archive_filename"
