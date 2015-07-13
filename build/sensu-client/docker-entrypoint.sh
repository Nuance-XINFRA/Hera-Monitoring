#!/bin/bash
set -e

export PATH=$PATH:/etc/sensu/plugins:/etc/sensu/handlers 

if [ "$1" = 'start' ]; then
    exec /opt/sensu/bin/sensu-client \
        -c /etc/sensu/config.json -d /etc/sensu/conf.d \
        -e /etc/sensu/extensions -v \
        "$@"
fi

exec "$@"