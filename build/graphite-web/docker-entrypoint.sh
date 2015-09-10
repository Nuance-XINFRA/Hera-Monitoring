#!/bin/bash
set -e

if [ "$1" = 'graphiteweb' ]; then
	chmod 777 /graphite_web_init_script.sh
    ./graphite_web_init_script.sh
    exec /usr/sbin/apache2ctl -D FOREGROUND
fi

exec "$@"
