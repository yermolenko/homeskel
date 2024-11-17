#!/bin/bash

squashfs_mountpoint=${1:-./squashfs}

[ -d "$squashfs_mountpoint" ] || { echo "ERROR: squashfs mountpoint \"$squashfs_mountpoint\" does not exist"; exit 1; }

sync
umount "$squashfs_mountpoint" || exit 1
rmdir "$squashfs_mountpoint" || exit 1
sync
