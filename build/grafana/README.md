# Available Custom Configurations through environmental variables #

The following tweaks are made available in the docker-entrypoint.sh in order to ease the customization of grafana configuration at docker containers startup.

## HERA_GRAFANA_LOCAL_GRAPHITE_PORT ##

Defining this Environment variables with a non-empty value (such as "80") will automatically update the grafana configurations under /usr/share/grafana/config.js to point to the graphite container running on the same host with the specified port exposed.

## HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT ##

Defining this Environment variable with a non-empty value (such as "9200") will automatically update the grafana configurations under /usr/share/grafana/config.js to point to the elasticsearch container running on the same host with the specified port exposed.

NOTE: in order to avoid cross-origin resource sharing (CORS) issues between grafana and elasticsearch, a custom proxy is setup on the apache2 config under /etc/apache2/apache2.conf to redirect requests to elasticsearch running on the same host with the specified port exposed.

## HERA_GRAFANA_INIT_SCRIPT_LOG_VERBOSE ##

Defining this Environment variable (regardless of the value) allows the explicit logging of the steps performed by the initialization script to the container stdout.
