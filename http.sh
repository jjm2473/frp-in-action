#!/bin/bash
# github.com/jjm2473/frp-in-action

METHOD=
HOST=
PORT=
URL_PATH=
HTTP_VERSION=

setPreHead() {
    METHOD=$1
    HTTP_VERSION=$3
    URL_PATH=`echo "$2" | sed 's/^http:\/\///g'`
    HOST=`echo "$URL_PATH" | egrep -o '^[^/]+'`
    URL_PATH=`echo "$URL_PATH" | egrep -o '/.*'`
    if echo "$HOST" | fgrep -q ':'; then
        PORT=`echo "$HOST" | awk -F ':' '{print $2}'`
        HOST=`echo "$HOST" | awk -F ':' '{print $1}'`
    else 
        PORT=80
    fi
}

readHeaders() {
    read LINE || exit 1
    while [ ${#LINE} -gt 1 ]; do
        echo "$LINE" | egrep -v '^Proxy-'
        read LINE || exit 1
    done
    echo -ne "\r\n"
}

doPlain() {
    echo "$METHOD $URL_PATH $HTTP_VERSION"
    readHeaders
    dd bs=1 2>/dev/null
}

read LINE
[ -z "$LINE" ] && exit 1
setPreHead $LINE

# echo "PREHEAD: $METHOD $HOST $PORT $URL_PATH $HTTP_VERSION" >&2
if [ "$METHOD" == "CONNECT" ]; then
    readHeaders >/dev/null
    echo -ne "HTTP/1.1 200 Connection Established\r\n\r\n"
    echo "CONNECT $HOST $PORT" >&2
    dd bs=1 2>/dev/null | nc $HOST $PORT
else
    echo "$METHOD $HOST $PORT" >&2
    doPlain | nc $HOST $PORT
fi