#!/bin/bash
# github.com/jjm2473/frp-in-action

socat TCP-LISTEN:8080,fork,reuseaddr EXEC:./http.sh
