#!/bin/bash
# github.com/jjm2473/frp-in-action

readbytes() {
    dd bs=1 count=$1 2>/dev/null
}

readu1() {
    readbytes $1 | od -An -t u1 | xargs echo
}

# version, always 0x05
readbytes 1 >/dev/null

# client supported METHODS_COUNT
NM=`readu1 1`

# read all client supported METHODS and ignore
readbytes $NM >/dev/null

# tell client we only support SOCKS5 (0x05) None auth (0x00)
echo -ne '\05\00'

# skip VERSION, COMMAND, RSV
readbytes 3 >/dev/null

# get ADDRESS_TYPE
AT=`readu1 1`
ADDR=""

if [ $AT == 3 ]; then
    # if named address, read host length
    HL=`readu1 1`
    # read host
    ADDR=`readbytes $HL`
else
    # else ip address
    ADDR=`readu1 4 | sed 's/ /./g'`
fi
# read port
PORT=$((`readu1 1` * 256 + `readu1 1`))
# response
echo -ne '\05\00\00\01\00\00\00\00\00\00'
# nc $ADDR $PORT
socat - TCP:$ADDR:$PORT
