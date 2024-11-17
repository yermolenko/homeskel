#!/bin/bash

dirname=${1:-.}

find "$dirname" -type d | wc -l
