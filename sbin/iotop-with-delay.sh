#!/bin/bash

delay=${1:-20}

iotop --only --delay="$delay"
