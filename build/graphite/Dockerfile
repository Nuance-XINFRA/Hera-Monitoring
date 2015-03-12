FROM 		nuancemobility/ubuntu-base:14.04
MAINTAINER 	Brice Argenson <brice.argenson@nuance.com>

# Install Graphite Carbon
RUN 		apt-get update -y && \
            	apt-get install -y graphite-carbon && \
			echo "CARBON_CACHE_ENABLED=true" > /etc/default/graphite-carbon			

# Install Graphite Web
RUN		apt-get install -y python-pip && pip install django==1.4
RUN 		apt-get install -y graphite-web apache2 apache2-mpm-worker libapache2-mod-wsgi
# Configure httpd
RUN 		rm -f /etc/apache2/sites-enabled/000-default.conf && \
			cp /usr/share/graphite-web/apache2-graphite.conf /etc/apache2/sites-enabled/graphite.conf && \
			echo "\nHeader set Access-Control-Allow-Origin \"*\"\n" >> /etc/apache2/apache2.conf && \
			echo "Header set Access-Control-Allow-Methods \"GET, OPTIONS\"\n" >> /etc/apache2/apache2.conf && \
			echo "Header set Access-Control-Allow-Headers \"origin, authorization, accept\"\n" >> /etc/apache2/apache2.conf && \
			a2enmod headers

VOLUME 		/etc/carbon
VOLUME 		/var/lib/graphite

EXPOSE		2003 
EXPOSE 		80

COPY 		supervisor 	/etc/supervisor/conf.d
