#!/bin/bash

TEMP_FILE="/tmp/hello.txt"

touch "$TEMP_FILE"

while true; do
    echo "Hello world" >> "$TEMP_FILE"
    sleep 10
done
