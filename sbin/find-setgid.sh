#!/bin/bash

dirname=${1:-.}

find "$dirname" -mount \
     -perm -2000 \
     -type f \
     -exec ls -la {} \;
