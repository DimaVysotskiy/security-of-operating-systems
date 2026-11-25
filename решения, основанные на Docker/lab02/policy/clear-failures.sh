#!/bin/sh
case "${1:-}" in
    user[1-4]) rm -f -- "/var/run/faillock/$1" ;;
esac
