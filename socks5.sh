#!/bin/bash
# github.com/jjm2473/frp-in-action

readbytes() {
    dd bs=1 count=$1 2>/dev/null
}

readu1() {
    readbytes $1 | hexdump -ve '1/1 " %u"' | dd bs=1 skip=1 2>/dev/null
}

skipver() {
    local ver=`readu1 1`
    if [ $ver -ne 5 ]; then
        echo "Unsupported Version $VER" >&2
        exit 1
    fi
}

## handshake req
# read version, always 0x05
skipver

# client supported METHODS_COUNT
NM=`readu1 1`

# read all client supported METHODS and ignore
[ $NM -gt 0 ] && readbytes $NM >/dev/null

## handshake resp
# tell client we only support SOCKS5 (0x05) None auth (0x00)
echo -ne '\05\00'

## command req
# skip VERSION, get COMMAND, skip RSV
skipver
COMMAND=`readu1 1`
if [ $COMMAND -ne 1 -a $COMMAND -ne 3 ]; then
    echo "Unknown COMMAND $COMMAND" >&2
    # not supportd command
    echo -ne '\05\07\00\01\00\00\00\00\00\00'
    exit 1
fi
readbytes 1 >/dev/null

# get ADDRESS_TYPE
AT=`readu1 1`
ADDR=""

if [ $AT == 3 ]; then
    # if named address, read host length
    HL=`readu1 1`
    # read host
    ADDR=`readbytes $HL`
elif [ $AT == 1 ]; then
    # else ipv4 address
    ADDR=`readu1 4 | sed 's/ /./g'`
else
    echo "Unsupported ADDRESS_TYPE $AT" >&2
    echo -ne '\05\04\00\01\00\00\00\00\00\00'
    exit 1
fi
# read port
PORT=$((`readu1 1` * 256 + `readu1 1`))

## command resp
# response
echo -ne '\05\00\00\01\00\00\00\00\00\00'

PROTO="TCP"
[ $COMMAND -eq 3 ] && PROTO="UDP"

# nc $ADDR $PORT
TARGET=$PROTO:$ADDR:$PORT
[ -n "$1" ] && TARGET=$TARGET,bindtodevice=$1

echo "CONNECT TO $TARGET" >&2
exec socat - $TARGET
