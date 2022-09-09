#!/bin/bash
# github.com/jjm2473/frp-in-action

hostsformat() {
    local name=$1
    local ip
    shift
    for ip in $*; do
        echo $ip $name
    done
}

json2line() {
    local line
    while read; do
        line="$REPLY"
        if [ -n "$line" ]; then
            hostsformat `echo "$line" | jsonfilter -q -e '@.Answer[0].name' -e '@.Answer[*].data'`
        fi
    done
}

json2line > /var/etc/remote_hosts.txt.new

if [ -s /var/etc/remote_hosts.txt.new ];then
    cat /var/etc/remote_hosts.txt.new > /var/etc/remote_hosts.txt
    /etc/init.d/dnsmasq reload
fi
