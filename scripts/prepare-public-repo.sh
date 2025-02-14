#!/usr/bin/env bash

set -euo pipefail

printf "Cloning repo to temp dir...\n"
dir=$(mktemp -d)
git clone --no-local . "$dir"

cleanup() {
    if [[ -n "${dir:-}" ]] && [[ -d "$dir" ]]; then
        printf "\nCleaning up temporary directory...\n"
        rm -rf "$dir"
    fi
}
trap cleanup EXIT ERR INT TERM

printf "\nFiltering repo omitting private data...\n"
cd "$dir"
git filter-repo \
    --invert-paths \
    --path secrets \
    --path .sops.yaml \
    --path hosts/work-laptop \
    --path modules/home/work

printf "\nPopulating private facing stubs...\n"
cp -r ./scripts/public-stubs/. .
git add -A
git commit -m "Populating redacted public facing stubs"

printf "\nPulling exsisting public repo...\n"
git remote add public https://github.com/TimQuelch/nixos-config-public
git remote set-url --push public git@github.com:TimQuelch/nixos-config-public
git fetch public

printf "\nRebasing onto public master branch...\n"
git config advice.skippedCherryPicks false
git rebase --verbose public/master

# Count new commits
NEW_COMMITS=$(git rev-list --count "public/master"..HEAD)

# Check if there are any new commits
if [[ "$NEW_COMMITS" -eq 0 ]]; then
    printf "\nNo new commits to push. Exiting.\n"
    exit 0
fi

printf "\n\e[1;34mNew commits to be pushed:\e[0m\n"
git log --pretty=format:"%C(yellow)%h%Creset %s" "public/master"..HEAD

read -r -t 30 -p $'\e[1;33mDo you want to push these changes to the public repository? (y/N): \e[0m' confirm || confirm="n"

confirm=$(echo "${confirm:-n}" | tr '[:upper:]' '[:lower:]' | xargs)

if [[ "$confirm" == "y" || "$confirm" == "yes" ]]; then
    printf "\nPushing to public repository...\n"
    git push --force-with-lease public HEAD:master
    printf "\nPush completed successfully.\n"
else
    printf "\nPush cancelled.\n"
fi
