#!/bin/bash

read -p "Are you sure to make $PWD read-only recursively? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo ""
    exit 1
fi

echo ""
echo -n "Making $PWD read-only recursively ... "

chmod -R -w ./ && echo "DONE."
