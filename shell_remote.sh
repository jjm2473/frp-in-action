
hosts() {
    cat <<-EOF
google.com
youtube.com
EOF
}

resolv() {
    curl --fail -H 'accept: application/dns-json' "https://cloudflare-dns.com/dns-query?name=$1&type=A"
}

resolv_hosts() {
    local line
    while read; do
        line="$REPLY"
        if [ -n "$line" ]; then
            resolv $line && echo ""
        fi
    done
}

hosts | resolv_hosts
