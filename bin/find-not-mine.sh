#!/bin/bash

dirname=${1:-.}

find "$dirname" -mount \
     -path '*.avfs*' -prune \
     -o \
     \( ! -user `id -un` -o ! -group `id -gn` \) \
     -print
