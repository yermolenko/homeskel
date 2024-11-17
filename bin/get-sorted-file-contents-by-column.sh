#!/bin/bash

filename=${1:?Filename is required}
column=${2:-1}

export LANG=C

cat "$filename" | sort -k "$column"
