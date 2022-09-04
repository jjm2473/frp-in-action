#!/bin/bash
# github.com/jjm2473/frp-in-action

[ -z "$1" -o -z "$2" -o -z "$3" ] && exit 1

HOST=$1
URL_PATH=$2

setPreHead() {
    [ "HTTP/1.1" = "$1" -a "101" = "$2" ] || exit 1
}

readHeaders() {
    read LINE || exit 1
    while [ ${#LINE} -gt 1 ]; do
        read LINE || exit 1
    done
}

echo -ne "GET $URL_PATH HTTP/1.1\r\nHost: $HOST\r\nConnection: Upgrade\r\nPragma: no-cache\r\nUpgrade: websocket\r\nAccept-Encoding: plain\r\n\r\n"

read LINE
[ -z "$LINE" ] && exit 1
setPreHead $LINE

readHeaders >/dev/null

shift
shift

if [[ "$1" == ":"* ]]; then
    socat fd:${1#:} stdio
else
    $*
fi
