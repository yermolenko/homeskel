#!/bin/bash

username=${1:?Username is required}
dirname=${2:-.}

find "$dirname" -mount \
     -user "$username" \
     -print
