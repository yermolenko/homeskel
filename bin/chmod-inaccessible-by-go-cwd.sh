#!/bin/bash

echo -n "Checking the terminal ..." >&2 && [ -t 0 -a -t 2 ] && echo " OK" >&2 && \
    read -p "Are you sure to make $PWD accessible only by owner recursively? " -n 1 && \
    [[ $REPLY =~ ^[Yy]$ ]] && echo >&2 || { echo " Exiting." >&2; exit 1; }

echo ""

echo -n "chmod directories go-rwx ... "
find ./ -type d -exec chmod go-rwx {} \; || exit 1
echo "DONE."

echo -n "chmod files go-rwx ... "
find ./ -type f -exec chmod go-rwx {} \; || exit 1
echo "DONE."
