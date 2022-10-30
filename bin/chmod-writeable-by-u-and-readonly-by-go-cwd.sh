#!/bin/bash

echo -n "Checking the terminal ..." >&2 && [ -t 0 -a -t 2 ] && echo " OK" >&2 && \
    read -p "Are you sure to make $PWD writable by owner and read-only by group-and-others recursively? " -n 1 && \
    [[ $REPLY =~ ^[Yy]$ ]] && echo >&2 || { echo " Exiting." >&2; exit 1; }

echo ""

find ./ -type d -exec chmod u+rwx {} \; || exit 1
find ./ -type f -exec chmod u+rwX {} \; || exit 1

find ./ -type d -exec chmod go+rx {} \; || exit 1
find ./ -type f -exec chmod go+rX {} \; || exit 1
find ./ -type d -exec chmod go-w {} \; || exit 1
find ./ -type f -exec chmod go-w {} \; || exit 1
