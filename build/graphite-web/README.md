# Available Custom Configurations through environmental variables #

The following tweaks are made available in the docker-entrypoint.sh in order to ease the customization of the graphite-web configuration at docker containers startup.

## HERA_GRAPHITE_WEB_CARBONLINK_HOSTS ##

Defining this Environment variable will allow the overwriting of the default configuration of the graphite-web CARBONLINK_HOSTS setting under /etc/graphite/local_settings.py

- Setting the value to "AUTOLINK" will cause the init-script to auto discover the carbon-cache instances linked to this graphite-web container (containing "carboncache" in the names) and set them as CARBONLINK_HOSTS under /etc/graphite/local_settings.py with ports 7002.

- Setting the value to any other string (such as "[\"10.3.4.5:7002\", \"10.3.4.6:7002\"]") will overwrite the CARBONLINK_HOSTS setting under /etc/graphite/local_settings.py with the exact string value.

## HERA_GRAPHITE_WEB_CLUSTER_SERVERS ##

Defining this Environment variable with a non-empty value (such as "[\"10.3.4.5:80\", \"10.3.4.6:80\", \"10.3.4.5:81\", \"10.3.4.6:81\"]) will automatically overwrite the default CLUSTER_SERVERS setting under /etc/graphite/local_settings.py with the exact string value.

## HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER and HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT ##

Defining both of these Environment variables with a non-empty value (such as "3200" and "128") will automatically set the following configurations under /etc/apache2/apache2.conf which will help improve the query performance under load.

- MaxRequestWorkers ${HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER}
- ServerLimit ${HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT}

## HERA_GRAPHITE_WEB_APACHE2_THREADS and HERA_GRAPHITE_WEB_APACHE2_PROCESSES ##

Defining both of these Environment variables with a non-empty value (such as "250" and "5" depending on the machine cpu) will automatically set the following configurations under /etc/apache2/sites-enabled/graphite.conf which will help improve the query performance under load.

- WSGIDaemonProcess _graphite processes=${HERA_GRAPHITE_WEB_APACHE2_PROCESSES} threads=${HERA_GRAPHITE_WEB_APACHE2_THREADS} display-name='%{GROUP}' inactivity-timeout=120 user=_graphite group=_graphite

## HERA_GRAPHITE_WEB_INIT_SCRIPT_LOG_VERBOSE ##

Defining this Environment variable (regardless of the value) allows the explicit logging of the steps performed by the initialization script to the container stdout.
