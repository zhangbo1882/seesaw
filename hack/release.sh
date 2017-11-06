#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

set -x

set -a
# requires GITHUB_TOKEN=<TOKEN> in .env file
# export var as env variable
. .env
set +a

export GITHUB_API="${GITHUB_API:-https://github.corp.ebay.com/api/v3}"
export GITHUB_USER="${GITHUB_USER:-ufes-dev}"
export GITHUB_REPO="${GITHUB_REPO:-seesaw}"

git tag $1

# tag before make to ensure version info entered into binary
make

git push --tags
sleep 5

github-release info -u $GITHUB_USER -r $GITHUB_REPO || /bin/true
github-release release -u $GITHUB_USER -r $GITHUB_REPO -t $1
sleep 5

for cmd in seesaw_ncc seesaw_healthcheck healthcheck_test_tool; do
    github-release upload -u $GITHUB_USER -r $GITHUB_REPO -t $1 --name $cmd --file _output/$cmd
done
