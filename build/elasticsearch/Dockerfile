FROM 		nuancemobility/ubuntu-base:14.04
MAINTAINER 	Brice Argenson <brice.argenson@nuance.com>

RUN 		curl -s http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
			echo "deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main" > /etc/apt/sources.list.d/elasticsearch.list && \
			apt-get -y update && \
			apt-get install -y openjdk-7-jre-headless elasticsearch && \
			sed -i 's|#MAX_MAP_COUNT=262144|MAX_MAP_COUNT=|g' /etc/default/elasticsearch

ADD 		elasticsearch-curator.py  	/etc/cron.daily/

RUN 		curl -O https://bootstrap.pypa.io/get-pip.py && \
			python get-pip.py && \
			pip install --quiet elasticsearch-curator && \
			chmod +x /etc/cron.daily/elasticsearch-curator.py && \
			echo "@daily /etc/cron.daily/elasticsearch-curator.py\n" >> /etc/crontab

VOLUME 		/etc/elasticsearch
VOLUME 		/usr/share/elasticsearch/data

EXPOSE 		9200

COPY 		supervisor 	/etc/supervisor/conf.d