#!/bin/bash

days=${1:-1}
dirname=${2:-.}

echo "Searching for modifications in $dirname during last $days days ..."

find "$dirname" -mount \
     -daystart \
     -path "./lost+found" -prune -o \
     -path "./.avfs" -prune -o \
     -mtime -$days -print
