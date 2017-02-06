#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

set -x
# requires GITHUB_TOKEN=<TOKEN> in .env file
source .env

GITHUB_API="${GITHUB_API:-https://github.corp.ebay.com/api/v3}"
GITHUB_USER="${GITHUB_USER:-qiuyu}"
GITHUB_REPO="${GITHUB_REPO:-seesaw}"

git tag $1
git push --tags
sleep 5
github-release info -u $GITHUB_USER -r $GITHUB_REPO || /bin/true
sleep 5
github-release release -u $GITHUB_USER -r $GITHUB_REPO -t $1

for cmd in seesaw_ncc; do
    github-release upload -u $GITHUB_USER -r $GITHUB_REPO -t $1 --name $cmd --file _output/$cmd
done
