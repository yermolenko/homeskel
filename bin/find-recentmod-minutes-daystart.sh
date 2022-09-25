#!/bin/bash

minutes=${1:-5}
dirname=${2:-.}

echo "Searching for modifications in $dirname during last $minutes minutes ..."

find "$dirname" -mount \
     -daystart \
     -path "./lost+found" -prune -o \
     -path "./.avfs" -prune -o \
     -mmin -$minutes -print
