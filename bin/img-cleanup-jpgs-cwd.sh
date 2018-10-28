#!/bin/bash

echo -n "Checking the terminal ..." >&2 && [ -t 0 -a -t 2 ] && echo " OK" >&2 && \
    read -p "Are you sure you want to cleanup JPG files in $PWD? " -n 1 && \
    [[ $REPLY =~ ^[Yy]$ ]] && echo >&2 || { echo " Exiting." >&2; exit 1; }

echo -n "Cleaning up JPG files in $PWD ... "

gimp -i -b '(yaa-cleanup-images-batch "*.[Jj][Pp][Gg]" TRUE 30 30 3)' -b '(gimp-quit 0)'

echo "DONE."
