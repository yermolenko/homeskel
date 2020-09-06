#!/bin/bash

read -p "Are you sure to make $PWD accessible only by owner recursively? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo ""
    exit 1
fi

echo ""

echo -n "chmod directories go-rwx ... "
find ./ -type d -exec chmod go-rwx {} \; || exit 1
echo "DONE."

echo -n "chmod files go-rwx ... "
find ./ -type f -exec chmod go-rwx {} \; || exit 1
echo "DONE."
