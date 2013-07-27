#!/bin/bash

set -e
set -u

url_base="https://raw.github.com/tkawachi/corona-test-runner/develop"

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

if [ -a main.lua ]; then
    echo >&2 "Moving main.lua to app_main.lua"
    mv main.lua app_main.lua
fi

for f in main.lua test_main.lua lunatest.lua; do
    echo >&2 "Downloading $f"
    \curl -O ${url_base}/$f
done

echo >&2 "done!"
