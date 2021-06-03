#!/usr/bin/env bash

function help() {
    >&2 echo "usage: $0 [-f|--file FILE] [-l|--limit LIMIT] [-h|--help]"
    exit 1
}

file="$HOME/.gumball-urls"
limit=""

while (( $# )); do
    case "$1" in
        "-h" | "--help")
            help
            ;;
        "-f" | "--file")
            file=shift
            ;;
        "-l" | "--limit")
            limit=shift
            ;;
        *)
            >&2 echo "error: unknown flag $1. use -h for help"
            exit 1
    esac
done

if ! [ -r "$file" ]; then
    >&2 echo "error: could not access url file $file."
    exit 1
fi

if [ "$limit" != "" ]; then
    if ! [ "$limit" =~ [0-9]+$ ]; then
        >&2 echo "error: limit must be a valid integer."
        exit 1
    fi
    head -n "$limit" "$file" > "$file" 
    exit
fi 

url="$(shuf "$file" | head -n 1)"
IFS='/' read base <<< "$url"
found="$(curl -s "$url" | grep -Po '(?<=href=")[^"]*')"
while IFS= read -r add; do
    if [[ "$add" =~ ^https?:// ]]; then
        echo "$add" >> "$file"
    fi
done <<< "$found"
shuf "$file" > "tmp"
cat "tmp" > "$file"
rm "tmp"
sed -i /$url/d "$file"
echo "$url"
