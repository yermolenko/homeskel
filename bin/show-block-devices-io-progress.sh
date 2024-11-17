#!/bin/bash

grep -e Dirty: -e Writeback: /proc/meminfo

echo

ls /sys/block/ | while read device; do
    awk "{ printf \"%s %s\", \"$device: \", \$9 }" "/sys/block/$device/stat"
    ls -go --time-style=long-iso /dev/disk/by-id/ | \
        grep -- "$device" | \
        grep -v -- "-part" | \
        awk '{printf "   %s", $6}'
    echo
done

echo
