#!/usr/bin/env bash

set -eu

work="./blend-work/"

mkdir -p "$work"

jq -r '. | to_entries | .[] | [.key]+.value | @tsv' metadata.json |
  while IFS=$'\n' read -r line; do
      readarray -d $'\t' -t info < <(printf '%s' "$line")
      target_dir="$work"/"${info[0]}"
      mkdir -p "$target_dir"
      wget --random-wait -N -P "$target_dir" "${info[@]:1}"
      sleep 1
  done

[ "$BLEND_SKIP_ZIP" != "yes" ] && exec source ./02b-zip.sh
