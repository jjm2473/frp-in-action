#!/bin/bash
# github.com/jjm2473/frp-in-action

[ -z "$*" ] && exit 1

readHeaders() {
    read LINE || exit 1
    while [ ${#LINE} -gt 1 ]; do
        read LINE || exit 1
    done
}

handle_preheader() {
    export "HTTP_METHOD=$1"
    export "URL_PATH=$2"
}

read LINE
[ -z "$LINE" ] && exit 1

handle_preheader $LINE

readHeaders

echo -ne "HTTP/1.1 101 Switching Protocols\r\nConnection: upgrade\r\nUpgrade: WebSocket\r\n\r\n"

if [[ "$1" == ":"* ]]; then
    socat fd:${1#:} stdio
else
    $*
fi
