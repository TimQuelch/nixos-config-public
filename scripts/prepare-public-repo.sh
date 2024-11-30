#!/usr/bin/env bash

set -euo pipefail

printf "Cloning repo to temp dir...\n"
dir=$(mktemp -d)
git clone --no-local . "$dir"

printf "\n\nFiltering repo omitting private data...\n"
cd "$dir"
git filter-repo \
    --invert-paths \
    --path secrets \
    --path .sops.yaml \
    --path hosts/work-laptop \
    --path modules/home/work

printf "\n\nPopulating private facing stubs...\n"
cp -r ./scripts/public-stubs/. .
git add -A
git commit -m "Populating redacted public facing stubs"
