FROM 		nuancemobility/ubuntu-base:14.04
MAINTAINER 	Brice Argenson <brice.argenson@nuance.com>

# Install Sensu
RUN 		curl http://repos.sensuapp.org/apt/pubkey.gpg | apt-key add - && \
			echo "deb http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list && \
			apt-get -y update && apt-get install -y sensu

# Configure Sensu metrics collection
RUN 		apt-get install -y ruby ruby-dev build-essential git && \
			gem install sensu-plugin snmp --no-ri --no-rdoc && \
			apt-get install libsmi2ldbl && \
			curl -O http://launchpadlibrarian.net/134263381/smitools_0.4.8%2Bdfsg2-7_amd64.deb && \
			dpkg -i smitools_0.4.8%2Bdfsg2-7_amd64.deb && \
			rm -f smitools_0.4.8+dfsg2-7_amd64.deb

VOLUME 		/etc/sensu/conf.d
VOLUME 		/etc/sensu/plugins

COPY 		supervisor 	/etc/supervisor/conf.d