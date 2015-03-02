FROM 		nuancemobility/ubuntu-base:14.04
MAINTAINER 	Brice Argenson <brice.argenson@nuance.com>

# Install RabbitMQ
RUN 		apt-get update -y && \
			apt-get -y install erlang-nox && \
			curl -O http://www.rabbitmq.com/rabbitmq-signing-key-public.asc && \
			apt-key add rabbitmq-signing-key-public.asc && \
			echo "deb     http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list && \ 
			apt-get -y update && apt-get install -y rabbitmq-server && \
			rabbitmq-plugins enable rabbitmq_management --offline && \
			/etc/init.d/rabbitmq-server start && \
			rabbitmqctl add_vhost /sensu && \
			rabbitmqctl add_user sensu mypass && \
			rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"

# Install Redis
RUN 		apt-get install -y redis-server

# Install Sensu
RUN 		curl http://repos.sensuapp.org/apt/pubkey.gpg | apt-key add - && \
			echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list && \
			apt-get -y update && apt-get install -y sensu

# Install and configure WizardVan
RUN 		apt-get install -y git && \
			git clone http://github.com/opower/sensu-metrics-relay.git && \
			cp -R sensu-metrics-relay/lib/sensu/extensions/* /etc/sensu/extensions

# Install Sensu Plugins
RUN 		apt-get install -y ruby ruby-dev build-essential && \
			gem install mail --no-ri --no-rdoc -v 2.5.4 && \
			gem install sensu-plugin --no-ri --no-rdoc && \
			cd /etc/sensu/handlers && \
			curl -O https://raw.githubusercontent.com/sensu/sensu-community-plugins/master/handlers/notification/mailer.rb && \
			chmod +x mailer.rb

VOLUME 		/etc/sensu/conf.d
VOLUME 		/etc/rabbitmq

COPY 		supervisor 	/etc/supervisor/conf.d