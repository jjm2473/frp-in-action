#!/bin/bash
# github.com/jjm2473/frp-in-action

[ -z "$1" -o -z "$2" ] && exit 1

port=$1
url=$2

url=`echo "$url" | sed 's/:/\\\\:/g'`

socat tcp-listen:$port,bind=127.0.0.1,fork,reuseaddr exec:"./ws_connect.sh $url"
