#!/bin/bash

read -p "Are you sure to make $PWD writeable recursively? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo ""
    exit 1
fi

echo ""
echo -n "Making $PWD writeable recursively ... "

chmod -R +w ./ && echo "DONE."
