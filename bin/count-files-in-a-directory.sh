#!/bin/bash

dirname=${1:-.}

find "$dirname" -type f | wc -l
