#!/bin/bash
# github.com/jjm2473/frp-in-action

[ -z "$1" ] && exit 1

url=$1

url=`echo "$url" | sed 's/:/\\\\:/g'`

socat exec:"/bin/bash -s" exec:"./ws_connect.sh $url"
