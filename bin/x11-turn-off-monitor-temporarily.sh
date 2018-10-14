#!/bin/bash

off_duration=${1:-17}

echo "Turning the monitor off"
xset dpms force off

echo "Sleeping for $off_duration seconds"
sleep "$off_duration"

echo "Turning the monitor on"
xset dpms force on
