#!/usr/bin/env bash

# Init values.
file_path=""
target_path=""
verbose=0

# Usage
usage() {
    echo "Usage: $0 -f <zip file path> -t <usb device directory> [-v]"
    echo "  -v      Enable verbose output"
}

# Parse flags
while getopts "f:t:v" opt; do
    case $opt in
        f) file_path="$OPTARG" ;;
        t) target_path="$OPTARG" ;;
        v) verbose=1 ;;
        \?) echo "Error: Unknown flag -$OPTARG" >&2; usage ;;
        :) echo "Error: Falg -$OPTARG requires an arguemtn" >&2; usage ;;
    esac
done

# Enable verbose output
$verbose && set -x

if [ -z "$file_path" ] || [ -z "$target_path" ]; then
    echo "Error: -f is a required flags" >&2
    usage
    exit 1
fi

if [ ! -f "$file_path" ]; then
    echo "Error: zip file path $file_path not found" >&2
    exit 1
fi

tmp_dir=$(mktemp -d)
trap "rm -fr $tmp_dir" EXIT
unzip "$file_path" -d "$tmp_dir"

echo "Waiting for left device..."

while ! compgen -G "$target_path"/*XIAO* > /dev/null; do
    sleep 1
done

firmware_file=$(compgen -G "$tmp_dir"/*left* | head -n 1)
dest_dir=$(compgen -G "$target_path"/*XIAO* | head -n 1)


mv "$firmware_file" "$dest_dir"

echo "Left flashed"

echo "Waiting for right device..."

while ! compgen -G "$target_path"/*XIAO* > /dev/null; do
    sleep 1
done

firmware_file=$(compgen -G "$tmp_dir"/*right* | head -n 1)
dest_dir=$(compgen -G "$target_path"/*XIAO* | head -n 1)

mv "$firmware_file" "$dest_dir"

echo "Right flashed"

exit 0