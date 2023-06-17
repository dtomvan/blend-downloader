#!/bin/bash

work="./blend-work/"

mkdir -p "$work"

jq -r '. | to_entries | .[] | [.key]+.value | @tsv' metadata.json |
  while IFS=$'\n' read -r line; do
      readarray -d $'\t' -t info <<< "$line"
      target_dir="$work"/"${info[0]}"
      mkdir -p "$target_dir"
      wget -P "$target_dir" "${info[@]:1}"
  done

dt="$(date -Iseconds)"
cp -a "$work" blend-"$dt"/

zip -r blend-"$dt".zip blend-"$dt"/
