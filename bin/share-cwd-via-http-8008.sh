#!/bin/bash

hash python3 >/dev/null 2>&1 && \
    python3 -m http.server 8008 || \
        python -m SimpleHTTPServer 8008
