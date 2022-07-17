#!/bin/bash

hash qterminal 2>/dev/null && \
    qterminal -e sudo -i || lxterminal -e su -
