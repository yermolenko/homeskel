#!/bin/bash

dirname=${1:-.}

find "$dirname" -mount \
     -path '*.avfs*' -prune \
     -o \
     \( -type l \) \
     -print

# find ./ -type l | wc -l
# find ./ -type l -print0 | xargs -0 readlink
