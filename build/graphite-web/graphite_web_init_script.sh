#!/bin/bash


#######################################################
# logging
# NOTE: in your docker-compose, make sure the env variable HERA_GRAPHITE_WEB_INIT_SCRIPT_LOG_VERBOSE is set to enable verbose logging
#######################################################
function logInfo ( )
{
	if [ -z "$HERA_GRAPHITE_WEB_INIT_SCRIPT_LOG_VERBOSE" ]; then
		# do noting, logging diabled
		return;
	else
		echo $@
	fi	
}

#######################################################
# replace NbThread and NbProcesses settings in Hera GraphiteWeb Apache2 conf to improve performance
# NOTE: in your docker-compose, make sure the env variable HERA_GRAPHITE_WEB_APACHE2_THREADS is set to an integer value
#		ie, HERA_GRAPHITE_WEB_APACHE2_THREADS=250
# NOTE: in your docker-compose, make sure the env variable HERA_GRAPHITE_WEB_APACHE2_PROCESSES is set to an integer value
#		ie, HERA_GRAPHITE_WEB_APACHE2_PROCESSES=5
#######################################################
function replaceGraphiteWebApache2PerfSettingsThreadsAndProcesses ( )
{
	logInfo "calling replaceGraphiteWebApache2PerfSettings" 	
	
	# chech if the HERA_GRAPHITE_WEB_APACHE2_THREADS & HERA_GRAPHITE_WEB_APACHE2_PROCESSES environment variable is set
	if [ -z "$HERA_GRAPHITE_WEB_APACHE2_THREADS" ]; then
		logInfo "WARNING: \$HERA_GRAPHITE_WEB_APACHE2_THREADS env varialble is not set, this should have been done in the docker-compose.yml. nothing to do here!"
	else
		if [ -z "$HERA_GRAPHITE_WEB_APACHE2_PROCESSES" ]; then
			logInfo "WARNING: \$HERA_GRAPHITE_WEB_APACHE2_PROCESSES env varialble is not set, this should have been done in the docker-compose.yml. nothing to do here!"
		else		
			logInfo "\$HERA_GRAPHITE_WEB_APACHE2_THREADS is ${HERA_GRAPHITE_WEB_APACHE2_THREADS}"   
			logInfo "\$HERA_GRAPHITE_WEB_APACHE2_PROCESSES is ${HERA_GRAPHITE_WEB_APACHE2_PROCESSES}"   
			# remove white spaces
			HERA_GRAPHITE_WEB_APACHE2_THREADS_NO_WHITE_SPACES="$(echo -e "${HERA_GRAPHITE_WEB_APACHE2_THREADS}" | tr -d '[[:space:]]')"
			HERA_GRAPHITE_WEB_APACHE2_PROCESSES_NO_WHITE_SPACES="$(echo -e "${HERA_GRAPHITE_WEB_APACHE2_PROCESSES}" | tr -d '[[:space:]]')"
			logInfo "\$HERA_GRAPHITE_WEB_APACHE2_THREADS_NO_WHITE_SPACES is ${HERA_GRAPHITE_WEB_APACHE2_THREADS_NO_WHITE_SPACES}"   
			logInfo "\$HERA_GRAPHITE_WEB_APACHE2_PROCESSES_NO_WHITE_SPACES is ${HERA_GRAPHITE_WEB_APACHE2_PROCESSES_NO_WHITE_SPACES}"   
			# check how to interpret the value
			if [ ${HERA_GRAPHITE_WEB_APACHE2_THREADS_NO_WHITE_SPACES} == "" ]; then 			
				logInfo "WARNING: \$HERA_GRAPHITE_WEB_APACHE2_THREADS_NO_WHITE_SPACES env varialble is set to empty, this should have been set to a valid number (150) in the docker-compose.yml. nothing to do here!"
			else
				if [ ${HERA_GRAPHITE_WEB_APACHE2_PROCESSES_NO_WHITE_SPACES} == "" ]; then 			
					logInfo "WARNING: \$HERA_GRAPHITE_WEB_APACHE2_PROCESSES_NO_WHITE_SPACES env varialble is set to empty, this should have been set to a valid number (5) in the docker-compose.yml. nothing to do here!"
				else					
					# substitute values
					sed -i "/WSGIDaemonProcess _graphite processes=/c\WSGIDaemonProcess _graphite processes=${HERA_GRAPHITE_WEB_APACHE2_PROCESSES} threads=${HERA_GRAPHITE_WEB_APACHE2_THREADS} display-name='%{GROUP}' inactivity-timeout=120 user=_graphite group=_graphite" /etc/apache2/sites-enabled/graphite.conf
					#TODO-test# sed -i "/WSGIDaemonProcess _graphite processes=/c\	WSGIDaemonProcess _graphite processes=${HERA_GRAPHITE_WEB_APACHE2_PROCESSES} threads=${HERA_GRAPHITE_WEB_APACHE2_THREADS} display-name='%{GROUP}' inactivity-timeout=120 user=_graphite group=_graphite" etc_graphite_web/apache2/sites-enabled/graphite.conf	
				fi							
			fi				
		fi		
	fi	
}

#######################################################
# replace NbWorkers and ServerLimit settings in Hera GraphiteWeb Apache2 conf to improve performance
# NOTE: in your docker-compose, make sure the env variable HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER is set to an integer value
#		ie, HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER=3200
# NOTE: in your docker-compose, make sure the env variable HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT is set to an integer value
#		ie, HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT=128
#######################################################
function replaceGraphiteWebApache2PerfSettingsWorkerAndServerLimits ( )
{
	logInfo "calling replaceGraphiteWebApache2PerfSettingsWorkerAndServerLimits" 	
	
	# chech if the HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER & HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT environment variable is set
	if [ -z "$HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER" ]; then
		logInfo "WARNING: \$HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER env varialble is not set, this should have been done in the docker-compose.yml. nothing to do here!"
	else
		if [ -z "$HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT" ]; then
			logInfo "WARNING: \$HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT env varialble is not set, this should have been done in the docker-compose.yml. nothing to do here!"
		else		
			logInfo "\$HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER is ${HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER}"   
			logInfo "\$HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT is ${HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT}"   
			# remove white spaces
			HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER_NO_WHITE_SPACES="$(echo -e "${HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER}" | tr -d '[[:space:]]')"
			HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT_NO_WHITE_SPACES="$(echo -e "${HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT}" | tr -d '[[:space:]]')"
			logInfo "\$HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER_NO_WHITE_SPACES is ${HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER_NO_WHITE_SPACES}"   
			logInfo "\$HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT_NO_WHITE_SPACES is ${HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT_NO_WHITE_SPACES}"   
			# check how to interpret the value
			if [ ${HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER_NO_WHITE_SPACES} == "" ]; then 			
				logInfo "WARNING: \$HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER_NO_WHITE_SPACES env varialble is set to empty, this should have been set to a valid number (3200) in the docker-compose.yml. nothing to do here!"
			else
				if [ ${HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT_NO_WHITE_SPACES} == "" ]; then 			
					logInfo "WARNING: \$HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT_NO_WHITE_SPACES env varialble is set to empty, this should have been set to a valid number (128) in the docker-compose.yml. nothing to do here!"
				else					
					# substitute values
					echo "MaxRequestWorkers ${HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER}" >> /etc/apache2/apache2.conf
					#TODO-test# echo "MaxRequestWorkers ${HERA_GRAPHITE_WEB_APACHE2_MAX_REQUEST_WORKER}" >> etc_graphite_web/apache2/apache2.conf
					echo "ServerLimit ${HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT}" >> /etc/apache2/apache2.conf
					#TODO-test# echo "ServerLimit ${HERA_GRAPHITE_WEB_APACHE2_SERVER_LIMIT}" >> etc_graphite_web/apache2/apache2.conf
				fi							
			fi				
		fi		
	fi	
}

#######################################################
# replace default settings in Hera GraphiteWeb Apache2 conf to improve performance
#######################################################
function replaceGraphiteWebApache2PerfSettings ( )
{
	logInfo "calling replaceGraphiteWebApache2PerfSettings" 	
	# replace default nb of threads and processses
	replaceGraphiteWebApache2PerfSettingsThreadsAndProcesses
	# replace default nb of worker and server limit
	replaceGraphiteWebApache2PerfSettingsWorkerAndServerLimits
}

#######################################################
# replace the CLUSTER_SERVERS field in graphite-web\local_settings.py using the input values obtained from enviorment variable HERA_GRAPHITE_WEB_CLUSTER_SERVERS
# this is activated if env variable is defined 
# NOTE: in your docker-compose, make sure HERA_GRAPHITE_WEB_CLUSTER_SERVERS is set to either
#	 case1: for hera-top-nodes, the value should be the address:port of the graphite web instances running on the hera-collector-nodes (on port 80, 81, 82...etc)
#	        ie, in case of 3 hera collector nodes [10.3.4.5, 10.3.4.6 & 10.3.4.7] each running 2 instances of a graphite web on exposed ports 80 and 81, use:
#	        HERA_GRAPHITE_WEB_CLUSTER_SERVERS="[\"10.3.4.5:80\", \"10.3.4.6:80\", \"10.3.4.7:80\", \"10.3.4.5:81\", \"10.3.4.6:81\", \"10.3.4.7:81\"]
#	 case2: for hera-collector-nodes, the value should be "[]" as the graphite-web on collector nodes MUST NOT INTERCOMUNICATE.
#	        ie, HERA_GRAPHITE_WEB_CLUSTER_SERVERS=[]
#######################################################
function replaceGraphiteWebClusterServersSettings ( )
{
	logInfo "calling replaceGraphiteWebClusterServersSettings" 
	
	# chech if the HERA_GRAPHITE_WEB_CLUSTER_SERVERS environment variable is set
	if [ -z "$HERA_GRAPHITE_WEB_CLUSTER_SERVERS" ]; then
		logInfo "WARNING: \$HERA_GRAPHITE_WEB_CLUSTER_SERVERS env varialble is not set, this should have been done in the docker-compose.yml. nothing to do here!"
	else
		logInfo "\$HERA_GRAPHITE_WEB_CLUSTER_SERVERS is ${HERA_GRAPHITE_WEB_CLUSTER_SERVERS}"   
		# remove white spaces
		HERA_GRAPHITE_WEB_CLUSTER_SERVERS_NO_WHITE_SPACES="$(echo -e "${HERA_GRAPHITE_WEB_CLUSTER_SERVERS}" | tr -d '[[:space:]]')"
		logInfo "\$HERA_GRAPHITE_WEB_CLUSTER_SERVERS_NO_WHITE_SPACES is ${HERA_GRAPHITE_WEB_CLUSTER_SERVERS_NO_WHITE_SPACES}"   
		# check how to interpret the value
		if [ ${HERA_GRAPHITE_WEB_CLUSTER_SERVERS_NO_WHITE_SPACES} == "" ]; then 			
			logInfo "WARNING: \$HERA_GRAPHITE_WEB_CLUSTER_SERVERS env varialble is set to empty, this should have been set to a [] or [\"1.2.3.4:80\",...etc] in the docker-compose.yml. nothing to do here!"
		else
			# TODO add further checking in future
			# substitute values in substitution in the /etc/graphite/local_settings.py
			sed -i "/CLUSTER_SERVERS = /c\\${HERA_GRAPHITE_WEB_CLUSTER_SERVERS}" /etc/graphite/local_settings.py
			#TODO-test# sed -i "/CLUSTER_SERVERS = /c\CLUSTER_SERVERS = ${HERA_GRAPHITE_WEB_CLUSTER_SERVERS}" etc_graphite_web/local_settings.py	
		fi
	fi	
}

#######################################################
# replace the CARBONLINK_HOSTS field in graphite-web\local_settings.py using auto discovered links to carboncaches
# this is activated if env variable HERA_GRAPHITE_WEB_CARBONLINK_HOSTS=AUTOLINK
# the links in /etc/hosts inside the container are generated automaticaly based on docker-compose
#######################################################
function replaceGraphiteWebCarbonLinkHostsWithEtcHosts ( )
{
	logInfo "calling replaceGraphiteWebCarbonLinkHostsWithEtcHosts" 
	
	# read the list of carboncache links from the /etc/hosts, removing the lines wiht _1 at the end.
	va_etchosts_carboncache_links=($(cat /etc/hosts | grep carboncache | awk {'print $2'} | grep -v '_1$'))
	#TODO-test# va_etchosts_carboncache_links=($(cat etc_hosts/hosts.txt | grep carboncache | awk {'print $2'} | grep -v '_1$'))

	#  create the new CARBONLINK_HOSTS to be set in graphite-web\local_settings.py file  based on the carboncache links found
	# echo "number of elements ${#va_etchosts_carboncache_links[@]}"
	if [ ${#va_etchosts_carboncache_links[@]} -gt 0 ]; then 
		va_carbon_link_hosts_from_carboncache_links="CARBONLINK_HOSTS = ["
		for (( i=0; i<${#va_etchosts_carboncache_links[@]}; i++ )); 
		do 
			# echo ${va_etchosts_carboncache_links[i]}:2004; 
			# append the carboncache to the destinations
			va_carbon_link_hosts_from_carboncache_links="$va_carbon_link_hosts_from_carboncache_links \"${va_etchosts_carboncache_links[i]}:7002\""
			# append a ',' or ] only if NOT the last element
			if [ $[$i+1] -ne ${#va_etchosts_carboncache_links[@]} ]; then 
				va_carbon_link_hosts_from_carboncache_links="$va_carbon_link_hosts_from_carboncache_links,"
			else
				va_carbon_link_hosts_from_carboncache_links="$va_carbon_link_hosts_from_carboncache_links]"			
			fi
		done
		logInfo "va_carbon_link_hosts_from_carboncache_links is ${va_carbon_link_hosts_from_carboncache_links}"
			
		# now that we have the new CARBONLINK_HOSTS, do the substitution in the /etc/graphite/local_settings.py
		sed -i "/CARBONLINK_HOSTS = /c\\${va_carbon_link_hosts_from_carboncache_links}" /etc/graphite/local_settings.py
		#TODO-test# sed -i "/CARBONLINK_HOSTS = /c\\${va_carbon_link_hosts_from_carboncache_links}" etc_graphite_web/local_settings.py	
	else
		logInfo "WARNING: NO carboncache links WERE FOUND in /etc/hosts!"
	fi
}
#######################################################

#######################################################
# replace the CARBONLINK_HOSTS field in graphite-web\local_settings.py using the input values obtained from enviorment variable HERA_GRAPHITE_WEB_CARBONLINK_HOSTS
# this is activated if env variable is defined and NOT set to "AUTOLINK", ex: HERA_GRAPHITE_WEB_CARBONLINK_HOSTS="[\"10.3.4.5:7002\", \"10.3.4.6:7002\", ...etc]"
# the value of the env variable HERA_GRAPHITE_WEB_CARBONLINK_HOSTS is set based on docker-compose
#######################################################
function replaceGraphiteWebCarbonLinkHostsWithEnvVar ( )
{
	logInfo "calling replaceGraphiteWebCarbonLinkHostsWithEnvVar" 
	
	# create the new CARBONLINK_HOSTS to be set in graphite-web\local_settings.py file based on the carboncache links found in HERA_GRAPHITE_WEB_CARBONLINK_HOSTS
	va_carbon_link_hosts_from_carboncache_links="CARBONLINK_HOSTS = ${HERA_GRAPHITE_WEB_CARBONLINK_HOSTS}"
	logInfo "va_carbon_link_hosts_from_carboncache_links is ${va_carbon_link_hosts_from_carboncache_links}"

	# now that we have the new CARBONLINK_HOSTS, do the substitution in the /etc/graphite/local_settings.py
	sed -i "/CARBONLINK_HOSTS = /c\\${va_carbon_link_hosts_from_carboncache_links}" /etc/graphite/local_settings.py
	#TODO-test# sed -i "/CARBONLINK_HOSTS = /c\\${va_carbon_link_hosts_from_carboncache_links}" etc_graphite_web/local_settings.py	
}
#######################################################

#######################################################
# replace the CARBONLINK_HOSTS field in graphite-web\local_settings.py based on the value of HERA_GRAPHITE_WEB_CARBONLINK_HOSTS
# NOTE: in your docker-compose, make sure HERA_GRAPHITE_WEB_CARBONLINK_HOSTS is set to either
#	 case4: for hera-top-nodes, hera-collector-nodes, the value should be "AUTOLINK" so that the carboncaches linked localy are used to directly.
#	        ie, HERA_GRAPHITE_WEB_CARBONLINK_HOSTS=AUTOLINK
#	 case1: for any other custom configuration, the value should be the address:port of the carboncaches to be used for querying the metrics NOT yet on disk
#	        HERA_GRAPHITE_WEB_CARBONLINK_HOSTS="[\"10.3.4.5:7002\", \"10.3.4.6:7002\"]"
#######################################################
function replaceGraphiteWebCarbonLinkHostsSettings ( )
{
	logInfo "calling replaceGraphiteWebCarbonLinkHostsSettings" 
	
	# chech if the HERA_GRAPHITE_WEB_CARBONLINK_HOSTS environment variable is set
	if [ -z "$HERA_GRAPHITE_WEB_CARBONLINK_HOSTS" ]; then
		logInfo "WARNING: \$HERA_GRAPHITE_WEB_CARBONLINK_HOSTS env varialble is not set, this should have been done in the docker-compose.yml. nothing to do here!"
	else
		logInfo "\$HERA_GRAPHITE_WEB_CARBONLINK_HOSTS is ${HERA_GRAPHITE_WEB_CARBONLINK_HOSTS}"   
		# remove white spaces
		HERA_GRAPHITE_WEB_CARBONLINK_HOSTS_NO_WHITE_SPACES="$(echo -e "${HERA_GRAPHITE_WEB_CARBONLINK_HOSTS}" | tr -d '[[:space:]]')"
		logInfo "\$HERA_GRAPHITE_WEB_CARBONLINK_HOSTS_NO_WHITE_SPACES is ${HERA_GRAPHITE_WEB_CARBONLINK_HOSTS_NO_WHITE_SPACES}"   
		# check how to interpret the value
		if [ ${HERA_GRAPHITE_WEB_CARBONLINK_HOSTS_NO_WHITE_SPACES} = "AUTOLINK" ]; then 
			replaceGraphiteWebCarbonLinkHostsWithEtcHosts
		else
			replaceGraphiteWebCarbonLinkHostsWithEnvVar
		fi
	fi
}

#######################################################
# main logic
#######################################################
logInfo 'START GRAPHITE_WEB INIT CONFIG SCRIPT!!'

# relace the CARBONLINK_HOSTS setting of graphite-web\local_settings.py
replaceGraphiteWebCarbonLinkHostsSettings

# relace the CLUSTER_SERVERS settings of graphite-web\local_settings.py
replaceGraphiteWebClusterServersSettings

# replace the default performance settings in apache2
replaceGraphiteWebApache2PerfSettings

logInfo 'END GRAPHITE_WEB INIT CONFIG SCRIPT!!'
