#!/bin/bash
while IFS= read -r line; do  ##Internal Field Separator (IFS) is used to read the line as it is without trimming leading/trailing spaces
    echo "$line"
done < "$1"