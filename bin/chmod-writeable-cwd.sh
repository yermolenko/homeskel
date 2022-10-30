#!/bin/bash

echo -n "Checking the terminal ..." >&2 && [ -t 0 -a -t 2 ] && echo " OK" >&2 && \
    read -p "Are you sure to make $PWD writeable recursively? " -n 1 && \
    [[ $REPLY =~ ^[Yy]$ ]] && echo >&2 || { echo " Exiting." >&2; exit 1; }

echo ""
echo -n "Making $PWD writeable recursively ... "

chmod -R +w ./ && echo "DONE."
