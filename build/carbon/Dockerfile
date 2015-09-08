FROM        nuancemobility/ubuntu-base:14.04
MAINTAINER  Brice Argenson <brice.argenson@nuance.com>

RUN         apt-get update -y && \
            apt-get install -y graphite-carbon && \
            echo "CARBON_CACHE_ENABLED=true" > /etc/default/graphite-carbon         

VOLUME      /etc/carbon
VOLUME      /var/lib/graphite/whisper

COPY        docker-entrypoint.sh /
COPY        carbon_cache_relay_init_script.sh /

ENTRYPOINT  ["/docker-entrypoint.sh"]

EXPOSE      2003 2004 7002 2013 2014

CMD         ["cache"]