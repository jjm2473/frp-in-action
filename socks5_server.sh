#!/bin/bash
# github.com/jjm2473/frp-in-action

socat TCP-LISTEN:1080,fork,reuseaddr EXEC:./socks5.sh
