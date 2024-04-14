#!/usr/bin/env bash

set -euxo pipefail

query() {
    printf "htmlq -- '%s'" "$@"
}

declare -a metadata metadata_t
metadata_t=(
    normal
    # cristmas
)
mapfile -d '' metadata < <(printf "metadata-%s.json\0" "${metadata_t[@]}")
q_normal="div.fusion-fullwidth:nth-child(2) > div:nth-child(1) > .fusion-layout-column > .fusion-column-wrapper"
# q_christmas="div.fusion-fullwidth:nth-child(5) > div:nth-child(1) > .fusion-layout-column > .fusion-column-wrapper"

do_query() {
    curl -fsSL -H @headers.in https://blendassen.nl/mp3s-en-bladmuziek/    \
    | pee "$(query "$*")"                                           \
    | pandoc -f html -t json --lua-filter utils/convert-to-dict.lua \
    | python utils/pretty-json.py
}

for i in ${metadata_t[@]}
do
    do_query "$(eval echo \$"q_$i")" > "metadata-$i.json"
done

# do_query "$q_christmas"                                     \
#     | jq '. | with_entries(.key |= "Kerstreportoire/\(.)")' \
#     > "${metadata[1]}"

jq -s 'reduce .[] as $i ({}; . * $i)' ${metadata[@]} > metadata.json
