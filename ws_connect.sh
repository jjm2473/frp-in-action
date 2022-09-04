#!/bin/bash
# github.com/jjm2473/frp-in-action

# Following regex is based on https://tools.ietf.org/html/rfc3986#appendix-B with
# additional sub-expressions to split authority into userinfo, host and port
#
readonly URI_REGEX='^(([^:/?#]+):)?(//((([^:/?#]+)@)?([^:/?#]+)(:([0-9]+))?))?(/([^?#]*))(\\?([^#]*))?(#(.*))?'
#                    ↑↑            ↑  ↑↑↑            ↑         ↑ ↑            ↑ ↑        ↑  ↑        ↑ ↑
#                    |2 scheme     |  ||6 userinfo   7 host    | 9 port       | 11 rpath |  13 query | 15 fragment
#                    1 scheme:     |  |5 userinfo@             8 :…           10 path    12 ?…       14 #…
#                                  |  4 authority
#                                  3 //…


if [[ "$1" =~ $URI_REGEX ]]; then
    scheme=${BASH_REMATCH[2]}
    host=${BASH_REMATCH[7]}
    port=${BASH_REMATCH[9]} # maybe empty
    path=${BASH_REMATCH[10]}
    query=${BASH_REMATCH[12]} # maybe empty

    # echo "$scheme://$host:$port$path$query"
    exec 3>&1 <&0
    cmd="./ws_wrap.sh $host"
    [ -z "$port" ] || cmd="$cmd\\:$port"
    cmd="$cmd $path$query \\:3"

    peer=""
    if [ "https" = "$scheme" ]; then
        [ -z "$port" ] && port="443"
        peer=openssl:"$host:$port"
    else
        [ -z "$port" ] && port="80"
        peer=tcp-connect:"$host:$port"
    fi

    socat exec:"$cmd" "$peer"
else
    exit 1
fi
