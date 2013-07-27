#!/bin/bash

set -e
set -u

function check_file() {
    file="$1"
    if [ -a "$file" ]; then
        echo >&2 "ERROR: $file already exists"
        exit 1
    fi
}

for f in app_main.lua test_main.lua lunatest.lua; do
    check_file $f
done

