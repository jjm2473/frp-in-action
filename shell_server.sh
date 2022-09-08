#!/bin/bash
# github.com/jjm2473/frp-in-action

socat tcp-listen:17000,fork,reuseaddr exec:'./ws_unwrap.sh ./ws_route.sh'
