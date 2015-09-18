#!/bin/bash


#######################################################
# logging
# NOTE: in your docker-compose, make sure the env variable HERA_GRAFANA_INIT_SCRIPT_LOG_VERBOSE is set to enable verbose logging
#######################################################
function logInfo ( )
{
	if [ -z "$HERA_GRAFANA_INIT_SCRIPT_LOG_VERBOSE" ]; then
		# do noting, logging diabled
		return;
	else
		echo $@
	fi	
}

#######################################################
# replace default settings in Hera config.js to point to localhost elasticsearch
# NOTE: in your docker-compose, make sure the env variable HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT is set to a valid port
#       ie HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT="9200"
#######################################################
function replaceGrafanaElasticSearchUrlSettings ( )
{
	logInfo "calling replaceGrafanaElasticSearchUrlSettings" 
	
	# chech if the HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT environment variable is set
	if [ -z "$HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT" ]; then
		logInfo "WARNING: \$HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT env varialble is not set, this should have been done in the docker-compose.yml. nothing to do here!"
	else
		logInfo "\$HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT is ${HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT}"   
		# remove white spaces
		HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT_NO_WHITE_SPACES="$(echo -e "${HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT}" | tr -d '[[:space:]]')"
		logInfo "\$HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT_NO_WHITE_SPACES is ${HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT_NO_WHITE_SPACES}"   
		# check how to interpret the value
		if [ ${HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT_NO_WHITE_SPACES} == "" ]; then 			
			logInfo "WARNING: \$HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT env varialble is set to empty, this should have been set to a valid port (eg. \"9200\")  in the docker-compose.yml. nothing to do here!"
		else
			# TODO add further checking in future
			# substitute values in config.js (must use cp -f....device may be locked)
			cp -f /usr/share/grafana/config.js /usr/share/grafana/config-grafana-init-script-backup.js
			sed -i "s_url: \"https://\" + window.location.hostname + \"/elasticsearch/\"_url: \"http://\" + window.location.host + \"/elasticsearch\"_" /usr/share/grafana/config-grafana-init-script-backup.js
			cp -f /usr/share/grafana/config-grafana-init-script-backup.js /usr/share/grafana/config.js 
			# create redirect in apache2 conf to avoid the CORS issues (redirects from grafana java_script)
			echo "ProxyPass /elasticsearch/ http://elasticsearch:${HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT_NO_WHITE_SPACES}/" >> /etc/apache2/apache2.conf
			echo "ProxyPassReverse /elasticsearch/ http://elasticsearch:${HERA_GRAFANA_LOCAL_ELASTICSEARCH_PORT_NO_WHITE_SPACES}/" >> /etc/apache2/apache2.conf
		fi
	fi	
}

#######################################################
# replace default settings in Hera config.js to point to localhost graphite
# NOTE: in your docker-compose, make sure the env variable HERA_GRAFANA_LOCAL_GRAPHITE_PORT is set to a valid port
#       ie HERA_GRAFANA_LOCAL_GRAPHITE_PORT="80"
#######################################################
function replaceGrafanaGraphiteUrlSettings ( )
{
	logInfo "calling replaceGrafanaGraphiteUrlSettings" 
	
	# chech if the HERA_GRAFANA_LOCAL_GRAPHITE_PORT environment variable is set
	if [ -z "$HERA_GRAFANA_LOCAL_GRAPHITE_PORT" ]; then
		logInfo "WARNING: \$HERA_GRAFANA_LOCAL_GRAPHITE_PORT env varialble is not set, this should have been done in the docker-compose.yml. nothing to do here!"
	else
		logInfo "\$HERA_GRAFANA_LOCAL_GRAPHITE_PORT is ${HERA_GRAFANA_LOCAL_GRAPHITE_PORT}"   
		# remove white spaces
		HERA_GRAFANA_LOCAL_GRAPHITE_PORT_NO_WHITE_SPACES="$(echo -e "${HERA_GRAFANA_LOCAL_GRAPHITE_PORT}" | tr -d '[[:space:]]')"
		logInfo "\$HERA_GRAFANA_LOCAL_GRAPHITE_PORT_NO_WHITE_SPACES is ${HERA_GRAFANA_LOCAL_GRAPHITE_PORT_NO_WHITE_SPACES}"   
		# check how to interpret the value
		if [ ${HERA_GRAFANA_LOCAL_GRAPHITE_PORT_NO_WHITE_SPACES} == "" ]; then 			
			logInfo "WARNING: \$HERA_GRAFANA_LOCAL_GRAPHITE_PORT env varialble is set to empty, this should have been set to a valid port (eg. \"80\")  in the docker-compose.yml. nothing to do here!"
		else
			# TODO add further checking in future
			# substitute values in config.js (must use cp -f....device may be locked)
			cp -f /usr/share/grafana/config.js /usr/share/grafana/config-grafana-init-script-backup.js
			sed -i "s_url: \"https://\" + window.location.hostname + \"/graphite/\"_url: \"http://\" + window.location.hostname + \":${HERA_GRAFANA_LOCAL_GRAPHITE_PORT_NO_WHITE_SPACES}\"_" /usr/share/grafana/config-grafana-init-script-backup.js
			cp -f /usr/share/grafana/config-grafana-init-script-backup.js /usr/share/grafana/config.js
		fi
	fi	
}

#######################################################
# main logic
#######################################################
logInfo 'START GRAFANA INIT CONFIG SCRIPT!!'

# replace the default Hera settings in config.js & apache2.conf to point to loclahost elasticsearch
replaceGrafanaElasticSearchUrlSettings

# replace the default Hera settings in config.js & apache2.conf to point to loclahost graphite
replaceGrafanaGraphiteUrlSettings

logInfo 'END GRAFANA INIT CONFIG SCRIPT!!'
