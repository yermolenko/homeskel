#!/bin/bash

dirname=${1:-.}

find "$dirname" -mount \
     -path '*.avfs*' -prune \
     -o \
     \( ! -type l -a ! -readable \) -print

# \( ! -perm -u+r \)
