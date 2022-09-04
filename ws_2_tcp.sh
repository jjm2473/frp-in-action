#!/bin/bash
# github.com/jjm2473/frp-in-action

[ -z "$1" -o -z "$2" -o -z "$3" ] && exit 1

port=$1
dhost=$2
dport=$3

socat tcp-listen:$port,fork,reuseaddr exec:"./ws_unwrap.sh socat stdio tcp-connect\\:$dhost\\:$dport"
