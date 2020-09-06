#!/bin/bash

dirname=${1:-.}

find "$dirname" -mount \
     -path '*.avfs*' -prune \
     -o \
     \( \
     \( -type f -a ! -perm -644 \) \
     -o \
     \( -type d -a ! -perm -755 \) \
     \) \
     -print
