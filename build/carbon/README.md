# Available Custom Configurations through environmental variables #

The following tweaks are made available in the docker-entrypoint.sh in order to ease the customization of the carbon-cache or carbon-relay configuration at docker containers startup.

## HERA_CARBON_RELAY_DESTINATIONS ##

Defining this Environment variable will allow the overwriting of the default configuration of the carbon-relay DESTINATIONS setting under /etc/carbon/carbon.conf

- Setting the value to "AUTOLINK" will cause the init-script to auto discover the carbon-cache instances linked to this carbon-relay container (containing "carboncache" in the names) and set them as DESTINATIONS under /etc/carbon/carbon.conf with ports 2004.

- Setting the value to any other string (such as "10.3.4.5:2004:x, 10.3.4.6:2004:x, 10.3.4.7:2004:x, 10.3.4.5:2014:y, 10.3.4.6:2014:y, 10.3.4.7:2014:y") will overwrite the DESTINATIONS setting under /etc/carbon/carbon.conf with the exact string value.

## HERA_CARBON_CACHE_RETENTION ##

Defining this Environment variable with a non-empty value (such as "60s:7200s") will automatically overwrite the default retention of "retentions = 60s:14d" configuration if defined under /etc/carbon/storage-schemas.conf.

## HERA_CARBON_MAX_CREATES_PER_MINUTE ##

Defining this Environment variable with a non-empty value (such as "500") will automatically set the following configurations if defined under /etc/carbon/carbon.conf which will help improve the performance up to what the disc IO write speed allows.

- MAX_CREATES_PER_MINUTE = ${HERA_CARBON_MAX_CREATES_PER_MINUTE}
- LOG_CACHE_QUEUE_SORTS = False
- ENABLE_LOGROTATION = True
- USE_INSECURE_UNPICKLER = True

## HERA_CARBON_INIT_SCRIPT_LOG_VERBOSE ##

Defining this Environment variable (regardless of the value) allows the explicit logging of the steps performed by the initialization script to the container stdout.
