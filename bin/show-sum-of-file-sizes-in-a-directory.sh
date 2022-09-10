#!/bin/bash

dirname=${1:-.}

find "$dirname" -type f -print0 | xargs -r0 du -csb | tail -n 1
