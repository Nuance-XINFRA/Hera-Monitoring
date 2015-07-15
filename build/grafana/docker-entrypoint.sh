#!/bin/bash
set -e

if [[ "$1" == "-c" ]]; then
    if [[ "$2" != /usr/share/grafana/config.js ]]; then
        cp -f $2 /usr/share/grafana/config.js
    fi
    exec /usr/sbin/apache2ctl -D FOREGROUND
fi

exec "$@"
