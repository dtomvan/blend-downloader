#!/bin/bash

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

dt="$(date -Iseconds)"

target_dir=blend-"$dt"/
zipfile=blend-"$dt".zip

ln -s "$work" "$target_dir"
zip -r "$zipfile" "$target_dir"
rm "$target_dir"
