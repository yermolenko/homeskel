#!/bin/bash

time1=${1:?Two timestamps are required}
time2=${2:?Two timestamps are required}
dirname=${3:-.}

find "$dirname" -mount \
     -path "./lost+found" -prune -o \
     -path "./.avfs" -prune -o \
     -path "./.mozilla" -prune -o \
     -path "./.icedove" -prune -o \
     -newermt "$time1" ! -newermt "$time2" -print

     # -path "./proc" -prune -o \
     # -path "./sys" -prune -o \
     # -path "./run" -prune -o \
     # -path "./var/run" -prune -o \
     # -path "./dev" -prune -o \
     # -path "./mnt" -prune -o \
