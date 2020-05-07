#!/bin/bash

set -e

echo "Job started: $(date)"

if [[ $DATE_FOLDER ]]; then
    if [[ $S3_PATH != *\/ ]]; then
        echo "ERROR: S3_PATH must end in /"
        exit 1
    fi
    S3_PATH=$S3_PATH$(date +"$DATE_FOLDER")/
    echo "S3_PATH=$S3_PATH"
fi

/usr/local/bin/s3cmd sync $PARAMS "$DATA_PATH" "$S3_PATH"

echo "Job finished: $(date)"
