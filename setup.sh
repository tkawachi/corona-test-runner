#!/bin/bash

set -e
set -u

url_base="https://raw.github.com/tkawachi/corona-test-runner/develop"

function error() {
    echo >&2 "ERROR: $1"
    exit 1
}

function check_file() {
    file="$1"
    if [ -a "$file" ]; then
        error "$file already exists"
    fi
}

for f in app_main.lua app_main_test.lua test_main.lua lunatest.lua; do
    check_file $f
done

if [ -a main.lua ]; then
    echo >&2 "Moving main.lua to app_main.lua"
    mv main.lua app_main.lua
else
    error "main.lua not found"
fi

for f in test_main.lua lunatest.lua app_main_test.lua main.lua; do
    echo >&2 "Downloading $f"
    \curl -O ${url_base}/$f
done

echo >&2 "done!"
