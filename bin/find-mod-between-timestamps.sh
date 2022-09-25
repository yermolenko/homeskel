#!/bin/bash

time1=${1:?Two timestamps are required}
time2=${2:?Two timestamps are required}
dirname=${3:-.}

find "$dirname" -mount \
     -path "./lost+found" -prune -o \
     -path "./.avfs" -prune -o \
     -newermt "$time1" ! -newermt "$time2" -print
