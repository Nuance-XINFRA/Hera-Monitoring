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
# replace default settings in Hera config.js to point to loclahost elasticsearch
# NOTE: in your docker-compose, make sure the env variable HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL is set to a valid url (eg. "http://" + window.location.hostname + ":9200" )
#       ie HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL="\"http://\" + window.location.hostname + \":9200\""
#######################################################
function replaceGrafanaElasticSearchUrlSettings ( )
{
	logInfo "calling replaceGrafanaElasticSearchUrlSettings" 
	
	# chech if the HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL environment variable is set
	if [ -z "$HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL" ]; then
		logInfo "WARNING: \$HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL env varialble is not set, this should have been done in the docker-compose.yml. nothing to do here!"
	else
		logInfo "\$HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL is ${HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL}"   
		# remove white spaces
		HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL_NO_WHITE_SPACES="$(echo -e "${HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL}" | tr -d '[[:space:]]')"
		logInfo "\$HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL_NO_WHITE_SPACES is ${HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL_NO_WHITE_SPACES}"   
		# check how to interpret the value
		if [ ${HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL_NO_WHITE_SPACES} == "" ]; then 			
			logInfo "WARNING: \$HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL env varialble is set to empty, this should have been set to a valid url (eg. (eg. \"http://\" + window.location.hostname + \":9200\" ))  in the docker-compose.yml. nothing to do here!"
		else
			# TODO add further checking in future
			# substitute values in config.js
			sed -i "/\/elasticsearch\//c\url: ${HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL}," /usr/share/grafana/config.js
			#TODO-test# sed -i "/\/elasticsearch\//c\url: ${HERA_GRAFANA_LOCAL_ELASTICSEARCH_URL}," grafana/config.js
		fi
	fi	
}

#######################################################
# replace default settings in Hera config.js to point to loclahost graphite
# NOTE: in your docker-compose, make sure the env variable HERA_GRAFANA_LOCAL_GRAPHITE_URL is set to a valid url (eg. "http://" + window.location.hostname + ":9200" )
#       ie HERA_GRAFANA_LOCAL_GRAPHITE_URL="\"http://\" + window.location.hostname + \":80\""
#######################################################
function replaceGrafanaGraphiteUrlSettings ( )
{
	logInfo "calling replaceGrafanaGraphiteUrlSettings" 
	
	# chech if the HERA_GRAFANA_LOCAL_GRAPHITE_URL environment variable is set
	if [ -z "$HERA_GRAFANA_LOCAL_GRAPHITE_URL" ]; then
		logInfo "WARNING: \$HERA_GRAFANA_LOCAL_GRAPHITE_URL env varialble is not set, this should have been done in the docker-compose.yml. nothing to do here!"
	else
		logInfo "\$HERA_GRAFANA_LOCAL_GRAPHITE_URL is ${HERA_GRAFANA_LOCAL_GRAPHITE_URL}"   
		# remove white spaces
		HERA_GRAFANA_LOCAL_GRAPHITE_URL_NO_WHITE_SPACES="$(echo -e "${HERA_GRAFANA_LOCAL_GRAPHITE_URL}" | tr -d '[[:space:]]')"
		logInfo "\$HERA_GRAFANA_LOCAL_GRAPHITE_URL_NO_WHITE_SPACES is ${HERA_GRAFANA_LOCAL_GRAPHITE_URL_NO_WHITE_SPACES}"   
		# check how to interpret the value
		if [ ${HERA_GRAFANA_LOCAL_GRAPHITE_URL_NO_WHITE_SPACES} == "" ]; then 			
			logInfo "WARNING: \$HERA_GRAFANA_LOCAL_GRAPHITE_URL env varialble is set to empty, this should have been set to a valid url (eg. (eg. \"http://\" + window.location.hostname + \":9200\" ))  in the docker-compose.yml. nothing to do here!"
		else
			# TODO add further checking in future
			# substitute values in config.js
			sed -i "/\/graphite\//c\url: ${HERA_GRAFANA_LOCAL_GRAPHITE_URL}," /usr/share/grafana/config.js
			#TODO-test# sed -i "/\/graphite\//c\url: ${HERA_GRAFANA_LOCAL_GRAPHITE_URL}," grafana/config.js
		fi
	fi	
}

#######################################################
# main logic
#######################################################
logInfo 'START GRAFANA INIT CONFIG SCRIPT!!'

# replace the default Hera settings in config.js to point to loclahost elasticsearch
replaceGrafanaElasticSearchUrlSettings

# replace the default Hera settings in config.js to point to loclahost elasticsearch
replaceGrafanaGraphiteUrlSettings

logInfo 'END GRAFANA INIT CONFIG SCRIPT!!'
