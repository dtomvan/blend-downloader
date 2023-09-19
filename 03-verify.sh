#!/usr/bin/env bash

tempfiles=()

PREFIX="$1"

set -eu
if [ -z "$PREFIX" ]; then
    read -p 'Prefix > ' PREFIX
fi

evaluate() {
    eval $1="$PREFIX"-"$1".zip
    listvar=${1}_list
    temp="$(mktemp)"
    tempfiles+=("$temp")
    eval $listvar="$temp"
    eval zipinfo -1 "\$$1" > "$temp"
    countvar=${1}_count
    amount="$(cat $temp | wc -l)"
    eval $countvar="$amount"
}

evaluate audio
evaluate pdf

expected_total="$(jq '. | values | flatten | length' metadata.json)"
expected_pdf="$(jq '. | values | flatten[] | select(endswith("pdf"))' metadata.json | wc -l)"
expected_audio=$(($expected_total - $expected_pdf))
actual_total=$(($audio_count + $pdf_count))

echo "Amount of audio files in the archive: $audio_count"
echo "Amount of pdf files in the archive: $pdf_count"
echo "Expected total amount of files: $expected_total"
echo "Actual total amount of files: $actual_total"
echo "Expected amount of pdf files: $expected_pdf"
echo "Expected amount of audio files by deduction: $expected_audio"

[ -z "$(comm -1 -2 ${tempfiles[@]:0:2} | tr -d '\n')" ] && echo "No overlapping files found in the archives." || echo "Overlapping files found between the two archives."

grep blend-work ${tempfiles[@]} && echo "Files were referenced in blend-work. Archive will not extract as expected." || echo "No files references in blend-work/."

for i in ${tempfiles[@]}; do
    rm "$i"
done
