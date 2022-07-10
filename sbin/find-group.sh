#!/bin/bash

groupname=${1:?Groupname is required}
dirname=${2:-.}

find "$dirname" -mount \
     -group "$groupname" \
     -print
