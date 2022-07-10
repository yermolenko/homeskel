#!/bin/bash

megabytes=${1:-1}
seconds=${2:-30}

echo "Consuming $megabytes megabytes for $seconds seconds..."

bytes=$((1024**2*$megabytes))

cat <( </dev/zero head -c $bytes) <(sleep $seconds) | tail

echo "Consuming finished"
