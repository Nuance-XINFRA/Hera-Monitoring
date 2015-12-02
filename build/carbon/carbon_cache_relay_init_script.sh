#!/bin/bash


#######################################################
# logging
# NOTE: in your docker-compose, make sure the env variable HERA_CARBON_INIT_SCRIPT_LOG_VERBOSE is set to enable verbose logging
#######################################################
function logInfo ( )
{
	if [ -z "$HERA_CARBON_INIT_SCRIPT_LOG_VERBOSE" ]; then
		# do noting, logging diabled
		return;
	else
		echo $@
	fi	
}

#######################################################
# enables log rotation and disable LOGGING for Cache Queue Sorts and Listener Connections
#######################################################
function replaceCarbonDefaultLogging ()
{
	# substitute ENABLE_LOGROTATION value
	sed -i "/ENABLE_LOGROTATION = False/c\ENABLE_LOGROTATION = True" /etc/carbon/carbon.conf
	#TODO-test# sed -i "/ENABLE_LOGROTATION = False/c\ENABLE_LOGROTATION = True" etc_carbon_cache/carbon.conf
	# substitute LOG_CACHE_QUEUE_SORTS value
	sed -i "/LOG_CACHE_QUEUE_SORTS = True/c\LOG_CACHE_QUEUE_SORTS = False" /etc/carbon/carbon.conf
	#TODO-test# sed -i "/LOG_CACHE_QUEUE_SORTS = True/c\LOG_CACHE_QUEUE_SORTS = False" etc_carbon_cache/carbon.conf
	sed -i "/LOG_LISTENER_CONNECTIONS = True/c\LOG_LISTENER_CONNECTIONS = False" /etc/carbon/carbon.conf
	#TODO-test# sed -i "/LOG_LISTENER_CONNECTIONS = True/c\LOG_LISTENER_CONNECTIONS = False" etc_carbon_cache/carbon.conf
}

#######################################################
# replace default settings in Hera carboncache conf to improve performance
# NOTE: in your docker-compose, make sure the env variable HERA_CARBON_MAX_CREATES_PER_MINUTE is set to an integer value
#       ie HERA_CARBON_MAX_CREATES_PER_MINUTE=5000  (for 1 sample each 1 min, for 2 hours)
#######################################################
function replaceCarbonCacheConfPerformanceSettings ( )
{
	logInfo "calling replaceCarbonCacheConfPerformanceSettings" 	
	
	# chech if the HERA_CARBON_MAX_CREATES_PER_MINUTE environment variable is set
	if [ -z "$HERA_CARBON_MAX_CREATES_PER_MINUTE" ]; then
		logInfo "WARNING: \$HERA_CARBON_MAX_CREATES_PER_MINUTE env varialble is not set, this should have been done in the docker-compose.yml. nothing to do here!"
	else
		logInfo "\$HERA_CARBON_MAX_CREATES_PER_MINUTE is ${HERA_CARBON_MAX_CREATES_PER_MINUTE}"   
		# remove white spaces
		HERA_CARBON_MAX_CREATES_PER_MINUTE_NO_WHITE_SPACES="$(echo -e "${HERA_CARBON_MAX_CREATES_PER_MINUTE}" | tr -d '[[:space:]]')"
		logInfo "\$HERA_CARBON_MAX_CREATES_PER_MINUTE_NO_WHITE_SPACES is ${HERA_CARBON_MAX_CREATES_PER_MINUTE_NO_WHITE_SPACES}"   
		# check how to interpret the value
		if [ ${HERA_CARBON_MAX_CREATES_PER_MINUTE_NO_WHITE_SPACES} == "" ]; then 			
			logInfo "WARNING: \$HERA_CARBON_MAX_CREATES_PER_MINUTE env varialble is set to empty, this should have been set to a valid number (2000) in the docker-compose.yml. nothing to do here!"
		else			
			# substitute MAX_CREATES_PER_MINUTE value
			sed -i "/MAX_CREATES_PER_MINUTE = /c\MAX_CREATES_PER_MINUTE = ${HERA_CARBON_MAX_CREATES_PER_MINUTE}" /etc/carbon/carbon.conf
			#TODO-test# sed -i "/MAX_CREATES_PER_MINUTE = /c\MAX_CREATES_PER_MINUTE = ${HERA_CARBON_MAX_CREATES_PER_MINUTE}" etc_carbon_cache/carbon.conf
			# substitute USE_INSECURE_UNPICKLER value
			sed -i "/USE_INSECURE_UNPICKLER = False/c\USE_INSECURE_UNPICKLER = True" /etc/carbon/carbon.conf
			#TODO-test# sed -i "/USE_INSECURE_UNPICKLER = False/c\USE_INSECURE_UNPICKLER = True" etc_carbon_cache/carbon.conf
		fi
	fi	
	
}

#######################################################
# replace default settings in Hera storage-schemas.conf
# NOTE: in your docker-compose, make sure the env variable HERA_CARBON_CACHE_RETENTION is set to an integer value
#       ie HERA_CARBON_CACHE_RETENTION=60s:7200s  (for 1 sample each 1 min, for 2 hours)
#######################################################
function replaceCarbonCacheMetricsRetentionSettings ( )
{
	logInfo "calling replaceCarbonCacheMetricsRetentionSettings" 
	
	# chech if the HERA_CARBON_RELAY_DESTINATIONS environment variable is set
	if [ -z "$HERA_CARBON_CACHE_RETENTION" ]; then
		logInfo "WARNING: \$HERA_CARBON_CACHE_RETENTION env varialble is not set, this should have been done in the docker-compose.yml. nothing to do here!"
	else
		logInfo "\$HERA_CARBON_CACHE_RETENTION is ${HERA_CARBON_CACHE_RETENTION}"   
		# remove white spaces
		HERA_CARBON_CACHE_RETENTION_NO_WHITE_SPACES="$(echo -e "${HERA_CARBON_CACHE_RETENTION}" | tr -d '[[:space:]]')"
		logInfo "\$HERA_CARBON_CACHE_RETENTION_NO_WHITE_SPACES is ${HERA_CARBON_CACHE_RETENTION_NO_WHITE_SPACES}"   
		# check how to interpret the value
		if [ ${HERA_CARBON_CACHE_RETENTION_NO_WHITE_SPACES} == "" ]; then 			
			logInfo "WARNING: \$HERA_CARBON_CACHE_RETENTION env varialble is set to empty, this should have been set to a valid retention (60s:7200s) in the docker-compose.yml. nothing to do here!"
		else
			# TODO add further checking in future
			# substitute values in storage-schemas.conf
			sed -i "/retentions = 60s:14d/c\retentions = ${HERA_CARBON_CACHE_RETENTION}" /etc/carbon/storage-schemas.conf
			#TODO-test# sed -i "/retentions = 60s:14d/c\retentions = ${HERA_CARBON_CACHE_RETENTION}" etc_carbon_cache/storage-schemas.conf
		fi
	fi	
}

#######################################################
# replace the DESTINATIONS field in relay carbon.conf using auto discovered links to carboncaches
# this is activated if env variable HERA_CARBON_RELAY_DESTINATIONS=AUTOLINK
# the links in /etc/hosts inside the container are generated automaticaly based on docker-compose
#######################################################
function replaceCarbonRelayDestinationsWithEtcHosts ( )
{
	logInfo "calling replaceCarbonRelayDestinationsWithEtcHosts" 
	
	# read the list of carboncache links from the /etc/hosts, removing the lines wiht _1 at the end.
	va_etchosts_carboncache_links=($(cat /etc/hosts | grep carboncache | awk {'print $2'} | grep -v '_1$'))
	#TODO-test# va_etchosts_carboncache_links=($(cat etc_hosts/hosts.txt | grep carboncache | awk {'print $2'} | grep -v '_1$'))

	# create the new DESTINATIONS to be set in the carbon.conf file  based on the carboncache links found
	# echo "number of elements ${#va_etchosts_carboncache_links[@]}"
	if [ ${#va_etchosts_carboncache_links[@]} -gt 0 ]; then 
		va_destinations_from_carboncache_links="DESTINATIONS = "
		for (( i=0; i<${#va_etchosts_carboncache_links[@]}; i++ )); 
		do 
			# echo ${va_etchosts_carboncache_links[i]}:2004; 
			# append the carboncache to the destinations
			va_destinations_from_carboncache_links="$va_destinations_from_carboncache_links ${va_etchosts_carboncache_links[i]}:2004"
			# append a ',' only if NOT the last element
			if [ $[$i+1] -ne ${#va_etchosts_carboncache_links[@]} ]; then 
				va_destinations_from_carboncache_links="$va_destinations_from_carboncache_links,"
			fi
		done
		logInfo "va_destinations_from_carboncache_links is ${va_destinations_from_carboncache_links}"
		
		# now that we have the new destinations, do the substitution in the /etc/carbon/carbon.conf
		sed -i "/DESTINATIONS = /c\\${va_destinations_from_carboncache_links}" /etc/carbon/carbon.conf
		#TODO-test# sed -i "/DESTINATIONS = /c\\${va_destinations_from_carboncache_links}" etc_carbon_relay/carbon.conf
	else
		logInfo "WARNING: NO carboncache links WERE FOUND in /etc/hosts!"
	fi
}
#######################################################

#######################################################
# replace the DESTINATIONS field in relay carbon.conf using the input values obtained from enviorment variable HERA_CARBON_RELAY_DESTINATIONS
# this is activated if env variable is defined and NOT set to "AUTOLINK", ex: HERA_CARBON_RELAY_DESTINATIONS=10.3.2.1:2004,10.3.2.2:2004,...etc
# the value of the env variable HERA_CARBON_RELAY_DESTINATIONS is set based on docker-compose
#######################################################
function replaceCarbonRelayDestinationsWithEnvVar ( )
{
	logInfo "calling replaceCarbonRelayDestinationsWithEnvVar" 
	
	# create the new DESTINATIONS to be set in the carbon.conf file  based on the carboncache links found in HERA_CARBON_RELAY_DESTINATIONS
	va_destinations_from_carboncache_links="DESTINATIONS = ${HERA_CARBON_RELAY_DESTINATIONS}"
	logInfo "va_destinations_from_carboncache_links is ${va_destinations_from_carboncache_links}"

	# now that we have the new destinations, do the substitution in the /etc/carbon/carbon.conf
	sed -i "/DESTINATIONS = /c\\${va_destinations_from_carboncache_links}" /etc/carbon/carbon.conf
	#TODO-test# sed -i "/DESTINATIONS = /c\\${va_destinations_from_carboncache_links}" etc_carbon_relay/carbon.conf
	
}
#######################################################

#######################################################
# replace the DESTINATIONS field in relay carbon.conf based on the value of HERA_CARBON_RELAY_DESTINATIONS
# NOTE: in your docker-compose, make sure HERA_CARBON_RELAY_DESTINATIONS is set to either
#	 case1: for hera-top-nodes, the value should be the address:port of the OTHER relays instances running on the hera-collector-nodes (on port 2004, 2104, 2014 or 2114...etc)
#	        ie, in case of 3 hera collector nodes [10.3.4.5, 10.3.4.6 & 10.3.4.7] each running 2 instances of a carbonrelay on exposed ports 2004 and 2104, use:
#	        HERA_CARBON_RELAY_DESTINATIONS="10.3.4.5:2004:x, 10.3.4.6:2004:x, 10.3.4.7:2004:x, 10.3.4.5:2014:y, 10.3.4.6:2014:y, 10.3.4.7:2014:y"
#	 case2: for hera-collector-nodes, the value should be "AUTOLINK" so that the carboncaches linked localy are used to directly.
#	        ie, HERA_CARBON_RELAY_DESTINATIONS=AUTOLINK
#######################################################
function replaceCarbonRelayConfDestinationsSettings ( )
{
	logInfo "calling replaceCarbonRelayConfDestinationsSettings" 
	
	# chech if the HERA_CARBON_RELAY_DESTINATIONS environment variable is set to adjust the relay DESTINATIONS
	if [ -z "$HERA_CARBON_RELAY_DESTINATIONS" ]; then
		logInfo "WARNING: \$HERA_CARBON_RELAY_DESTINATIONS env varialble is not set, this should have been done in the docker-compose.yml. nothing to do here!"
	else
		logInfo "\$HERA_CARBON_RELAY_DESTINATIONS is ${HERA_CARBON_RELAY_DESTINATIONS}"   
		# remove white spaces
		HERA_CARBON_RELAY_DESTINATIONS_NO_WHITE_SPACES="$(echo -e "${HERA_CARBON_RELAY_DESTINATIONS}" | tr -d '[[:space:]]')"
		logInfo "\$HERA_CARBON_RELAY_DESTINATIONS_NO_WHITE_SPACES is ${HERA_CARBON_RELAY_DESTINATIONS_NO_WHITE_SPACES}"   
		# check how to interpret the value
		if [ ${HERA_CARBON_RELAY_DESTINATIONS_NO_WHITE_SPACES} = "AUTOLINK" ]; then 
			replaceCarbonRelayDestinationsWithEtcHosts
		else
			replaceCarbonRelayDestinationsWithEnvVar
		fi
	fi
}

#######################################################
# main logic
#######################################################
logInfo 'START CARBON INIT CONFIG SCRIPT!!'

#replace the default Logging options to False
replaceCarbonDefaultLogging

# relace the carbon relay DESTINATIONS setting
replaceCarbonRelayConfDestinationsSettings

# relace the default Hera settings in carbon.conf to improve performance
replaceCarbonCacheConfPerformanceSettings

# replace the retention period of the data in carbon storage-schemas.conf
replaceCarbonCacheMetricsRetentionSettings

logInfo 'END CARBON INIT CONFIG SCRIPT!!'
