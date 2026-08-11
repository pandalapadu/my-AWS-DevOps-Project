#!/bin/bash

SOURCE_DIR=$1
DAYS=${2:-14} #default 14 days if not provided

if [ -z "$SOURCE_DIR" ] || [ -z "$DAYS" ]; then
    echo "Usage: $0 <source_directory> [days(optional, default=14)]"
    exit 1
fi