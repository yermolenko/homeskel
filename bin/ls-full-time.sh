#!/bin/bash

dirname=${1:-.}

ls -la --full-time "$dirname"

# ls -la --time-style=full-iso "$dirname"
