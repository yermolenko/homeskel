#!/bin/bash

dirname=${1:-.}

find "$dirname" -type l | wc -l
