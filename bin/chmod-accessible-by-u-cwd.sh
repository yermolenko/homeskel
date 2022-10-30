#!/bin/bash

echo -n "Checking the terminal ..." >&2 && [ -t 0 -a -t 2 ] && echo " OK" >&2 && \
    read -p "Are you sure to make $PWD accessible by owner recursively? " -n 1 && \
    [[ $REPLY =~ ^[Yy]$ ]] && echo >&2 || { echo " Exiting." >&2; exit 1; }

echo ""

echo -n "chmod directories u+rwx ... "
find ./ -type d -exec chmod u+rwx {} \; || exit 1
echo "DONE."

echo -n "chmod files u+rwX ... "
find ./ -type f -exec chmod u+rwX {} \; || exit 1
echo "DONE."
