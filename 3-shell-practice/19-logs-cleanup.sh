#!/bin/bash

SOURCE_DIR=$1
DAYS=${2:-14} # default 14 days

if [ -z "$SOURCE_DIR" ]; then
    echo "ERROR:: Missing parameters"
    echo "USAGE:: $0 <source-dir> [days(optional default to 14)]"
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "ERROR:: Directory: $SOURCE_DIR does not exist"
    exit 1
fi

echo "Scanning $SOURCE_DIR for log files older than 14 days"
FILES=$(find $SOURCE_DIR -name "*.log" -type f -mtime +$DAYS)

if [ -z "$FILES" ]; then
    echo "No log files older than 14 days found"
    exit 0
fi

while IFS= read -r FILE
do
    echo "File to be deleted: $FILE"
    rm -f $FILE
    echo "File $FILE deleted"
done <<< "$FILES"

# < -> for file
# <<< -> variable