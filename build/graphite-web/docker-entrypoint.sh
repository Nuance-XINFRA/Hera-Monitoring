#!/bin/bash
set -e

if [ "$1" = 'graphiteweb' ]; then
    ./graphite_web_init_script.sh
    exec /usr/sbin/apache2ctl -D FOREGROUND
fi

exec "$@"
