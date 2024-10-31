#!/usr/bin/env bash

set -eu

if [ $# -lt 1 ]; then
    echo Need song name
    exit 1
fi

song="$1"
index="$song/index.txt"
mkdir -p "$song"

jq -r ". | to_entries | map(select(.key | startswith(\"$song\")) | .value) | flatten | .[]" metadata.json > "$index"

xargs wget --random-wait -N -P "$song" < "$index"
