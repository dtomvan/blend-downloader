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

dt="$(date -Iseconds | tr '|\\?*<\":>+[]/' '_')"

target_dir=blend-"$dt"
zipfile=blend-"$dt".zip
zipfile_pdf=blend-"$dt"-pdf.zip
zipfile_audio=blend-"$dt"-audio.zip

ln -s -T "$work" "$target_dir"

zip -r "$zipfile_pdf" "$target_dir"/*/*.pdf
find -L "$target_dir" -type f -exec sh -c "(file --mime-type -b '{}' | grep audio>/dev/null) || (file -b '{}' | grep -i audio>/dev/null)" \; -print0 | xargs -0 zip "$zipfile_audio"

rm "$target_dir"
