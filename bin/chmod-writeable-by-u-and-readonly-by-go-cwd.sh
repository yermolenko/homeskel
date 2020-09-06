#!/bin/bash

read -p "Are you sure to make $PWD writable by owner and read-only by group-and-others recursively? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo ""
    exit 1
fi

echo ""

find ./ -type d -exec chmod u+rwx {} \; || exit 1
find ./ -type f -exec chmod u+rwX {} \; || exit 1

find ./ -type d -exec chmod go+rx {} \; || exit 1
find ./ -type f -exec chmod go+rX {} \; || exit 1
find ./ -type d -exec chmod go-w {} \; || exit 1
find ./ -type f -exec chmod go-w {} \; || exit 1
