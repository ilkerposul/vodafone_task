#!/bin/bash

TEMP_FILE="/tmp/hello.txt"
PID_FILE="/var/run/hello_writer.pid"
SCRIPT_PATH="/home/ilker/vodafone_task/3_shell_scripting/hello.sh"

# scriptin pid dosyasını kontrol
if [ -f "$PID_FILE" ]; then
    HELLO_PID=$(cat "$PID_FILE")
else
    echo "pid dosyası bulunamadı: $PID_FILE"
    exit 1
fi

# script çıktısını kontrol (hello.txt)
if [ ! -f "$TEMP_FILE" ]; then
    echo "dosya bulunamadı: $TEMP_FILE"
    exit 1
fi

# satır sayısı kontrol
RECORD_COUNT=$(wc -l < "$TEMP_FILE")

echo "satır sayısı: $RECORD_COUNT"

if [ "$RECORD_COUNT" -ge 10 ]; then
    echo "satır sayısı 10'dan fazla. process restart ediliyor..."
    
    # processi kill et
    if kill "$HELLO_PID" 2>/dev/null; then
        echo "Process $HELLO_PID killed successfully"
    else
        echo "Could not kill process $HELLO_PID (may not exist)"
    fi
    
    # temp dosyasını sil
    rm -f "$TEMP_FILE"
    echo "Temp file removed: $TEMP_FILE"
    
    # restart
    setsid "$SCRIPT_PATH" > /dev/null 2>&1 &
    NEW_PID=$!
    echo "$NEW_PID" > "$PID_FILE"
    echo "New process started with PID: $NEW_PID"
fi
