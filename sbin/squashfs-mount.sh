#!/bin/bash

container_filename=${1:?Name of the squashfs file is required}
squashfs_mountpoint=${2:-./`basename "$container_filename"`-mnt}
# squashfs_mountpoint=${2:-./squashfs}

[ -e "$container_filename" ] || { echo "ERROR: \"$container_filename\" does not exist"; exit 1; }

[ -d "$squashfs_mountpoint" ] || mkdir -p "$squashfs_mountpoint"

[ -d "$squashfs_mountpoint" ] || { echo "ERROR: Cannot create squashfs mountpoint \"$squashfs_mountpoint\""; exit 1; }

mount "$container_filename" "$squashfs_mountpoint" || exit 1
