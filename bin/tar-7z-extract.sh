#!/bin/bash

archive_filename=${1:?Name of the existing archive is required}
target_directory=${2:-./}

[ -e "$archive_filename" ] || { echo "ERROR: \"$archive_filename\" does not exist"; exit 1; }

7za e -so "$archive_filename" | \
    tar x \
        --numeric-owner \
        -C "$target_directory" \
        -f -

if [ "${PIPESTATUS[*]}" != "0 0" ]; then
    echo "ERROR: Something went wrong"
fi

sync --file-system "$target_directory"
