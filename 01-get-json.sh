#!/usr/bin/env bash

set -euxo pipefail

query() {
    printf "htmlq -- '%s'" "$@"
}

q_normal="div.fusion-fullwidth:nth-child(3) > div:nth-child(1) > .fusion-layout-column > .fusion-column-wrapper"
q_christmas="div.fusion-fullwidth:nth-child(5) > div:nth-child(1) > .fusion-layout-column > .fusion-column-wrapper"

curl -fsSL -H @headers.in https://blendassen.nl/ledenpagina/        \
    | pee "$(query $q_normal)" "$(query $q_christmas)"              \
    | pandoc -f html -t json --lua-filter utils/convert-to-dict.lua \
    | python utils/pretty-json.py > metadata.json
