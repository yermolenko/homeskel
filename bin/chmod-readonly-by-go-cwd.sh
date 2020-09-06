#!/bin/bash

read -p "Are you sure to make $PWD read-only by group-and-others recursively? " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo ""
    exit 1
fi

echo ""

echo -n "chmod directories go+rx ... "
find ./ -type d -exec chmod go+rx {} \; || exit 1
echo "DONE."

echo -n "chmod files go+rX ... "
find ./ -type f -exec chmod go+rX {} \; || exit 1
echo "DONE."

echo -n "chmod directories go-w ... "
find ./ -type d -exec chmod go-w {} \; || exit 1
echo "DONE."

echo -n "chmod files go-w ... "
find ./ -type f -exec chmod go-w {} \; || exit 1
echo "DONE."
