#!/bin/bash

read -p "Are you sure to make $PWD accessible by owner recursively? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo ""
    exit 1
fi

echo ""

echo -n "chmod directories u+rwx ... "
find ./ -type d -exec chmod u+rwx {} \; || exit 1
echo "DONE."

echo -n "chmod files u+rwX ... "
find ./ -type f -exec chmod u+rwX {} \; || exit 1
echo "DONE."
