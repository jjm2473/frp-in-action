#!/bin/bash
# github.com/jjm2473/frp-in-action

readbytes() {
    dd bs=1 count=$1 2>/dev/null
}

readu1() {
    readbytes $1 | od -An -t u1 | xargs echo
}

readbytes 1 >/dev/null

NM=`readu1 1`
readbytes $NM >/dev/null
echo -ne '\05\00'

readbytes 3 >/dev/null
AT=`readu1 1`
ADDR=""
if [ $AT == 3 ]; then
    HL=`readu1 1`
    ADDR=`readbytes $HL`
else
    ADDR=`readu1 4 | sed 's/ /./g'`
fi
PORT=$((`readu1 1` * 256 + `readu1 1`))
echo -ne '\05\00\00\01\00\00\00\00\00\00'
nc $ADDR $PORT
