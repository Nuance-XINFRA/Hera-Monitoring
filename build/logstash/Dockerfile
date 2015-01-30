FROM 		nuancemobility/ubuntu-base:14.04
MAINTAINER 	Brice Argenson <brice.argenson@nuance.com>

# Install Logstash Package
RUN 		echo 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main' | tee /etc/apt/sources.list.d/logstash.list && \
			apt-get update -y && apt-get install -y logstash --force-yes

VOLUME		/etc/logstash/mib
VOLUME		/etc/logstash/conf.d
VOLUME		/etc/pki/tls

COPY 		supervisor 	/etc/supervisor/conf.d