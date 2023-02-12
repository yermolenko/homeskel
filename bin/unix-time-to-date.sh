#!/bin/bash

unix_time=${1:?"Unix time (the number of seconds) is required"}

date -d @"$unix_time"
