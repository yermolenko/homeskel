#!/bin/bash

f1=${1:?Filename is required}
editor=${2:-$EDITOR}

view-doc-as-text.sh "$1" "$2"
