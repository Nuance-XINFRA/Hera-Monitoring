#!/bin/bash
set -e

if [[ "$1" == -* ]]; then
    set -- /usr/sbin/nginx "$@"
elif [ -z "$1" ]; then
    exec /usr/sbin/nginx
fi

exec "$@"
