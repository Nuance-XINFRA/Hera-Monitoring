#!/bin/bash
set -e

if [ "$1" = 'graphiteweb' ]; then
    exec /usr/sbin/apache2ctl -D FOREGROUND
fi

exec "$@"
