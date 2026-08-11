#!/bin/bash

SOURCE_DIR=$1
DEST_DIR=$2
DAYS=${3:-14} # Default to 14 days if not provided

if [ -z "$SOURCE_DIR" ] || [ -z "$DEST_DIR" ]; then
    echo "Either source directory or destination directory empty"
    echo "USAGE:: $0 [source_dir] [dest_dir] [days:default 14]"
    exit 1
fi
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Source directory: $SOURCE_DIR does not exist"
    exit 1
fi

if [ ! -d "$DEST_DIR" ]; then
    echo "Destination directory: $DEST_DIR does not exist"
    exit 1
fi

FILES=(find "$SOURCE_DIR" -type f -name "*.log" -mtime +$DAYS)

if [ -z "$FILES" ]; then
    echo "Log files older than 14 days not found, nothing to do"
    exit 0
fi

while IFS= read -r FILE
do
    echo "$FILE"
done <<< "$FILES"