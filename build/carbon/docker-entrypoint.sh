#!/bin/bash
set -e

if [ "$1" = 'cache' ]; then
    ./carbon_cache_relay_init_script.sh
    exec /usr/bin/carbon-cache --config=/etc/carbon/carbon.conf --debug start "$@"
elif [ "$1" = 'relay' ]; then
    ./carbon_cache_relay_init_script.sh
    exec /usr/bin/carbon-relay --config=/etc/carbon/carbon.conf --debug start "$@"
elif [ "$1" = 'whisper' ]; then
    exec echo "Starting Whisper Data Container..."
fi

exec "$@"