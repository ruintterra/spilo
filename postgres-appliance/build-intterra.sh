#!/bin/bash

readonly REV=$(git rev-parse HEAD)
readonly URL=$(git config --get remote.origin.url)
readonly STATUS=$(git status --porcelain)
readonly GITAUTHOR=$(git show -s --format="%aN <%aE>" "$REV")

cat > scm-source.json <<__EOT__
{
    "url": "git:$URL",
    "revision": "$REV",
    "author": "$GITAUTHOR",
    "status": "$STATUS"
}
__EOT__

function run_or_fail() {
    "$@"
    local EXITCODE=$?
    if  [[ $EXITCODE != 0 ]]; then
        echo "'$@' failed with exitcode $EXITCODE"
        exit $EXITCODE
    fi
}


run_or_fail docker build -t spilo:squashed -f Dockerfile.build .
run_or_fail docker build -t registry.intterra.ru:5000/spilo:v3 .
docker push registry.intterra.ru:5000/spilo:v3
