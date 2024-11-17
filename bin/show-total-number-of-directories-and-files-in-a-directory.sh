#!/bin/bash

dirname=${1:-.}

export LANG=C

tree -a "$dirname" | grep -F "directories, "
