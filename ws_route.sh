#!/bin/bash

send_to_remote() {
    cat ./shell_remote.sh
    echo ""
    echo "sleep 5"
    echo "exit 0"
    echo ""
}

if [ "$URL_PATH" = "/console/ws/shell" ]; then
    send_to_remote &
    ./shell_local.sh
else
    socat stdio tcp-connect:127.0.0.1:7000
fi
