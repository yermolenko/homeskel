#!/bin/bash

find ./ -type f \
     -and -not -name sums.md5 \
     -and -not -name sums.cp1251.md5 \
     -and -not -name sums.utf8.md5 \
     -print0 | xargs -0 md5sum > ./sums.utf8.md5

konwert utf8-cp1251 ./sums.utf8.md5 -o ./sums.cp1251.md5
