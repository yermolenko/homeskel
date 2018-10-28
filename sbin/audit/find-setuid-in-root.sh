#!/bin/bash

find / \
     -path /media -prune -o \
     -path /mnt -prune -o \
     -path /proc -prune -o \
     -path /sys -prune -o \
     -path /run -prune -o \
     -perm -4000 \
     -type f \
     -exec ls -la {} \; > ./setuid-files-in-root-`date +"%Y%m%d_%H%M%S"`
