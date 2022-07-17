#!/bin/bash

hash qterminal 2>/dev/null && \
    qterminal -e mc "$@" || lxterminal -e mc "$@"
