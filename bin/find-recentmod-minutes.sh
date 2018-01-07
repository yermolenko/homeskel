#!/bin/bash

minutes=${1:-5}
dirname=${2:-.}

find "$dirname" -mount \
     -path "./lost+found" -prune -o \
     -path "./.avfs" -prune -o \
     -path "./.mozilla" -prune -o \
     -path "./.icedove" -prune -o \
     -mmin -$minutes -print

     # -path "./proc" -prune -o \
     # -path "./sys" -prune -o \
     # -path "./run" -prune -o \
     # -path "./var/run" -prune -o \
     # -path "./dev" -prune -o \
     # -path "./mnt" -prune -o \
