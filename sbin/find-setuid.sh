#!/bin/bash

dirname=${1:-.}

find "$dirname" -mount \
     -perm -4000 \
     -type f \
     -exec ls -la {} \;
