#!/bin/bash

SOURCE_DIR=$1
DAYS=${2:-14} #default 14 days if not provided

if [ -z "$SOURCE_DIR" ] || [ -z "$DAYS" ]; then
    echo "Usage: $0 <source_directory> [days(optional, default=14)]"
    exit 1
fi

if [ ! -d $SOURCE_DIR ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist."
    exit 1
fi

echo "Scanning $SOURCE_DIR for log files older than $DAYS days..."
Files=(find $SOURCE_DIR -name "*.log" -type f -mtime +$DAYS)

if [ -z "$Files" ]; then
    echo "No log files older than $DAYS days found in $SOURCE_DIR."
    exit 0
fi
while IFS= read -r FILE; do
    echo "files are Deleting: $FILE"
    rm -f "$FILE"
    echo "Deleted: $FILE"
done <<< "$Files"