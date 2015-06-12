FROM        nuancemobility/ubuntu-base:14.04
MAINTAINER  Brice Argenson <brice.argenson@nuance.com>

COPY        elasticsearch-curator.py    /etc/cron.hourly/

RUN         curl -O https://bootstrap.pypa.io/get-pip.py && \
            python get-pip.py && \
            pip install --quiet elasticsearch-curator && \
            chmod a+x /etc/cron.hourly/elasticsearch-curator.py && \
            touch /var/log/curator

COPY        crontab     /etc/crontab

VOLUME      /config

COPY        supervisor  /etc/supervisor/conf.d
