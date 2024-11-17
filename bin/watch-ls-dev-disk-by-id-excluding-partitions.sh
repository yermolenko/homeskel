#!/bin/bash

watch -n2 'ls -l /dev/disk/by-id/ | grep -v -- "-part"'
