#!/bin/bash
set -e

if [ "$1" = 'cache' ]; then
	chmod 777 /carbon_cache_relay_init_script.sh
    ./carbon_cache_relay_init_script.sh
    exec /usr/bin/carbon-cache --config=/etc/carbon/carbon.conf start --debug "$@"
elif [ "$1" = 'relay' ]; then
	chmod 777 /carbon_cache_relay_init_script.sh
    ./carbon_cache_relay_init_script.sh
    exec /usr/bin/carbon-relay --config=/etc/carbon/carbon.conf start --debug "$@"
elif [ "$1" = 'whisper' ]; then
    exec echo "Starting Whisper Data Container..."
fi

exec "$@"